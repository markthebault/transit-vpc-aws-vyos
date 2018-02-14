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
