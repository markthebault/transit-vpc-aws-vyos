all: upload-conf-vpc-1 upload-conf-vpc-2 reboot

upload-conf-vpc-1:
	./push-and-exec-vpn-conf.sh ssh-config vpc-1-vpn-config.vyos

upload-conf-vpc-2:
	./push-and-exec-vpn-conf.sh ssh-config vpc-2-vpn-config.vyos

reboot:
	ssh -F ssh-config vyos bash -c 'echo "Yes" | sudo reboot'
