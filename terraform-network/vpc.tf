module "vpc" {
 source = "terraform-aws-modules/vpc/aws"

  name = "mth-transit-vpc-1"
  cidr = "10.232.0.0/20"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.232.1.0/24", "10.232.2.0/24"]
  public_subnets  = ["10.232.10.0/24", "10.232.10.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}
