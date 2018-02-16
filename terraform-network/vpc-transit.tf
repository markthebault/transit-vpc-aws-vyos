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


resource "aws_customer_gateway" "vpc_transit_cgw" {
  bgp_asn    = 65013
  ip_address = "${aws_eip.vyos_instance.public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "vpc-transit-customer-gateway"
    Environment = "${var.environment}"
    Terraform = "true"
  }
}
#
#
# resource "aws_route" "route_vpc_1" {
#   count = "${length(aws_instance.vyos_instance.id)}"
#
#   route_table_id            = "${element(module.vpc_transit.public_route_table_ids, count.index)}"
#   destination_cidr_block    = "10.232.0.0/20"
#   instance_id               = "${aws_instance.vyos_instance.id}"
# }
#
# resource "aws_route" "route_vpc_2" {
#   count = "${length(aws_instance.vyos_instance.id)}"
#
#   route_table_id            = "${element(module.vpc_transit.public_route_table_ids, count.index)}"
#   destination_cidr_block    = "10.146.0.0/20"
#   instance_id               = "${aws_instance.vyos_instance.id}"
# }
