variable "aws_region" {
  default = "eu-west-1"
}
variable "aws_profile" {
  default = "default"
}
variable "environment" {
  default = "dev"
}

#Ubuntu 16.04 hvm ebs
variable "ami_ubuntu" {
  type = "map"
  default = {
    "eu-west-1" = "ami-c1167eb8"
    "ap-southeast-1" = "ami-a55c1dd9"
  }
}

variable "ami_vyos" {
}

variable "vyos_instance_type" {
  default = "m4.large"
}

variable "key_pair_public_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "key_pair_private_path" {
  default = "~/.ssh/id_rsa"
}

variable "vyos_user" {
  default = "vyos"
}
