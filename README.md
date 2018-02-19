# Open Source Transit VPC on AWS
This project will setup the necessary elements to create a transit VPC.
I will include a packer step to build our router image. This router will be based on the [VyOS 1.1.7](https://vyos.io).
The AMI could also be found on the AWS Market place for a very decent price.

Terraform will be used to provision the infrastructure. Combinated with python scripts terraform will also generate the IPSec configuration.
The IPSec configuration will be pushed by ssh, so make sure your private key is added to your ssh-agent.

![Transit VPC Schemas](https://github.com/markthebault/transit-vpc-aws-vyos/raw/master/transit-VPC-with-Vyos.png)

## Before starting
You need to install `terraform`, `packer` and some python libs `pip install -R tools/requirements.txt`

## Run all
You can easily deploy everything using the following command `make all` at the root project.
This will lunch sequencialy the following makes:
- vyos-image : create a vpc and build the AMI, tear down the vpc
- terraform-network: create all the environment
- vpn-generated-configurations: push the VPN conf into our VYOS router :)

## VyOS generation
In order to allow packer to build our AMI, packer needs to create an instance in a public subnet to boot and install the necessary dependencies for running VyOS.

A simple terraform vpc is provided to allow packer to deploy an instance. When the AMI is created the terraform environment will be destroyed.
This image is region dependant, if you change the region of your project you will need to rebuild the image.

## Transit VPC environment
For our case we will build 3 different VPCs, two will be normal VPCs and the third one will be the transit VPC.
In the transit VPC the VyOS instance(s) will be deployed in the public subnets.
Choose wisely your instance type if your are adapting this project for production purpose, the IPSec if very CPU consuming, better to choose a `C series` instances.

On the other VPCs we deploy a instance on each VPC in order to perform a ping.

## Generate the SSH configuration
Terraform extract the VPN configuration form the `VPN connections` on aws. These configurations are in XML.
So we need to convert them in VyAtta. An XSLT sheet is available in `tools/vyatta.xsl` to help to convert the XML in simple VyAtta format.
Then a python script is used to convert the VyAtta to be used in VyOS system.
While running this script also register the BGP routes to share. This script is based on the [following repo](https://github.com/mboret/aws-vyos)

If you add new VPC, don't forget to change the interfaces in the configuration. I performed this opperation by using a `sed` in the second terraform template to generate the configuration `terraform-network/vpc-2.tf line: 53`

## Improvements
I am not a network engineer, so the configuration of the VyOS might not be optimal. So far that I found messing to this project is:
- Redundancy for the VyOS instance (in a different AZ)
- Another VPC with shared services such as LDAP, DNS, Proxies...
- Logging on the VyOS
- Storing the VPN configuration in a S3 Bucket, connected with push event to lambda that execute a command on the VyOS to add the new VPN Configuration
