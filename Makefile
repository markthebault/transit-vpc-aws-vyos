all: packer terraform connect-vpcs

terraform:
	make --directory ./terraform-network all

packer:
	make --directory ./vyos-image all

connect-vpcs:
	make --directory ./vpn-generated-configurations all
