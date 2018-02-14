terraform:
	cd terraform && \
		terraform init && \
		terraform apply

packer:
	cd vyos-image && \
		sh run-packer
