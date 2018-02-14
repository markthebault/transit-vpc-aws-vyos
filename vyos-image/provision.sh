#!/bin/bash

set -ex
set -o pipefail

# Ensure this script is run as root
if [ "$(id -u)" -ne "0" ]; then
  exec sudo -E $0 "$@"
fi

# Global variable definition
vyos_iso_local=/tmp/vyos.iso
vyos_iso_url=http://packages.vyos.net/iso/release/${VYOS_VERSION}/vyos-${VYOS_VERSION}-amd64.iso

CD_ROOT=/mnt/cdrom
CD_SQUASH_ROOT=/mnt/cdsquash
SQUASHFS_IMAGE="${CD_ROOT}/live/filesystem.squashfs"

VOLUME_DRIVE=/dev/xvdf
ROOT_PARTITION=${VOLUME_DRIVE}1

WRITE_ROOT=/mnt/wroot
READ_ROOT=/mnt/squashfs
INSTALL_ROOT=/mnt/inst_root

# Fetch GPG key and VyOS image
curl -sSLfo ${vyos_iso_local} ${vyos_iso_url}
curl -sSLfo ${vyos_iso_local}.asc ${vyos_iso_url}.asc
curl -sSLf http://packages.vyos.net/vyos-release.gpg | gpg --import

# Verify ISO is valid
gpg --verify ${vyos_iso_local}.asc ${vyos_iso_local}

# Mount ISO
mkdir -p ${CD_ROOT}
mount -t iso9660 -o loop,ro ${vyos_iso_local} ${CD_ROOT}

# Verify files inside ISO image
cd ${CD_ROOT}
md5sum -c md5sum.txt

# Mount squashfs image from ISO
mkdir -p ${CD_SQUASH_ROOT}
mount -t squashfs -o loop,ro ${SQUASHFS_IMAGE} ${CD_SQUASH_ROOT}

# Obtain version information
vyos_version=$(awk '/^vyatta-version/{print $2}' ${CD_ROOT}/live/filesystem.packages)

# Prepare EBS volume
parted --script ${VOLUME_DRIVE} mklabel msdos
parted --script --align optimal ${VOLUME_DRIVE} mkpart primary 0% 100%
mkfs.ext4 ${ROOT_PARTITION}
parted --script ${VOLUME_DRIVE} set 1 boot
mkdir -p ${WRITE_ROOT}
mount -t ext4 ${ROOT_PARTITION} ${WRITE_ROOT}

# Create installation directory
mkdir -p ${WRITE_ROOT}/boot/${vyos_version}/live-rw

# Copy files from ISO to filesystem
cp -p ${SQUASHFS_IMAGE} ${WRITE_ROOT}/boot/${vyos_version}/${vyos_version}.squashfs
find ${CD_SQUASH_ROOT}/boot -maxdepth 1  \( -type f -o -type l \) -exec cp -dp {} ${WRITE_ROOT}/boot/${vyos_version}/ \;

# Mount squashfs from filesystem
mkdir -p ${READ_ROOT}
mount -t squashfs -o loop,ro ${WRITE_ROOT}/boot/${vyos_version}/${vyos_version}.squashfs ${READ_ROOT}

# Set up union root for post installation tasks
mkdir -p ${INSTALL_ROOT}
mkdir -p ${WRITE_ROOT}/boot/${vyos_version}/work
mount -t overlay -o "noatime,upperdir=${WRITE_ROOT}/boot/${vyos_version}/live-rw,lowerdir=${READ_ROOT},workdir=${WRITE_ROOT}/boot/${vyos_version}/work" none ${INSTALL_ROOT}

# Make sure that config partition marker exists
touch ${INSTALL_ROOT}/opt/vyatta/etc/config/.vyatta_config

# Copy default config file to config directory
chroot --userspec=root:vyattacfg ${INSTALL_ROOT} cp /opt/vyatta/etc/config.boot.default /opt/vyatta/etc/config/config.boot
chmod 0775 ${INSTALL_ROOT}/opt/vyatta/etc/config/config.boot

### Modify config to meet AWS EC2 AMI requirements

# Add interface eth0 and set address to dhcp
sed -i '/interfaces {/ a\    ethernet eth0 {\n\        address dhcp\n\    }' ${INSTALL_ROOT}/opt/vyatta/etc/config/config.boot

# Add service ssh and disable-password-authentication
sed -i '/system {/ iservice {\n\    ssh {\n\        disable-password-authentication\n\        port 22\n\    }\n}' ${INSTALL_ROOT}/opt/vyatta/etc/config/config.boot

# Set system host-name to VyOS-AMI
sed -i '/login {/ i\    host-name VyOS-AMI' ${INSTALL_ROOT}/opt/vyatta/etc/config/config.boot

# Change system login user vyos encrypted-password to '*'
sed -i '/encrypted-password/ c\                encrypted-password "*"' ${INSTALL_ROOT}/opt/vyatta/etc/config/config.boot

### Install GRUB boot loader

# Create GRUB directory
mkdir -p ${WRITE_ROOT}/boot/grub

# Mount and bind required filesystems for grub installation
mount --bind /dev ${INSTALL_ROOT}/dev
mount --bind /proc ${INSTALL_ROOT}/proc
mount --bind /sys ${INSTALL_ROOT}/sys
mount --bind ${WRITE_ROOT} ${INSTALL_ROOT}/boot

# Install grub to boot sector
chroot ${INSTALL_ROOT} grub-install --no-floppy --root-directory=/boot ${VOLUME_DRIVE}
cat -s <<EOF > ${WRITE_ROOT}/boot/grub/grub.cfg
set default=0
set timeout=0
menuentry "VyOS AMI (HVM) ${vyos_version}" {
  linux /boot/${vyos_version}/vmlinuz boot=live quiet vyatta-union=/boot/${vyos_version} console=ttyS0
  initrd /boot/${vyos_version}/initrd.img
}
EOF

# Install ec2 init script
cp /tmp/ec2-fetch-ssh-public-key ${INSTALL_ROOT}/etc/init.d/ec2-fetch-ssh-public-key

# Configure fstab for tmpfs
echo 'tmpfs /var/run tmpfs nosuid,nodev 0 0' > ${INSTALL_ROOT}/etc/fstab

# Unmount everything
cd
for path in boot dev sys proc; do
  umount ${INSTALL_ROOT}/${path}
done
umount ${INSTALL_ROOT}
rm -rf ${WRITE_ROOT}/boot/${vyos_version}/work
umount ${READ_ROOT}
umount ${WRITE_ROOT}
umount ${CD_SQUASH_ROOT}
umount ${CD_ROOT}
