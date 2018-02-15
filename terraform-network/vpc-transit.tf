module "vpc_transit" {
 source = "terraform-aws-modules/vpc/aws"

  name = "mth-transit-vpc-transit"
  cidr = "10.100.0.0/20"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  #private_subnets = ["10.100.1.0/24", "10.100.2.0/24"]
  public_subnets  = ["10.100.11.0/24", "10.100.12.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
