terraform:
	make --directory ./terraform-network all

packer:
	make --directory ./vyos-image all
