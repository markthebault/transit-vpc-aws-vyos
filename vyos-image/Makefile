all: terraform-start packer terraform-down output-ami

terraform-start:
	cd terraform && terraform init && terraform apply -auto-approve

packer:
	sh run-packer

terraform-down:
	cd terraform && terraform destroy -force

output-ami:
	echo ami_vyos=\"$(shell sh extract-ami-ids)\" >> ../terraform-network/terraform.tfvars
