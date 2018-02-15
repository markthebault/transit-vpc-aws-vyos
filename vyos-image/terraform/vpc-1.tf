module "vpc_vyos" {
 source = "terraform-aws-modules/vpc/aws"

  name = "mth-transit-vpc-tmp-vyos"
  cidr = "10.0.0.0/20"

  azs             = ["${var.aws_region}a",]
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
