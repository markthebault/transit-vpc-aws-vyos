module "vpc_2" {
 source = "terraform-aws-modules/vpc/aws"

  name = "mth-transit-vpc-2"
  cidr = "10.146.0.0/20"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  #private_subnets = ["10.146.1.0/24", "10.146.2.0/24"]
  public_subnets  = ["10.146.11.0/24", "10.146.12.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
