module "vpc_2" {
 source = "modules/vpc"

  name = "mth-transit-vpc-2"
  cidr = "10.146.0.0/20"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  #private_subnets = ["10.146.1.0/24", "10.146.2.0/24"]
  public_subnets  = ["10.146.11.0/24", "10.146.12.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = true
  vpn_gateway_amazon_side_asn = "65052"
  enable_dns_hostnames = true

  propagate_private_route_tables_vgw = true
  propagate_public_route_tables_vgw = true

  tags = {
    Terraform = "true"
    Environment = "${var.environment}"
  }
}




resource "aws_vpn_connection" "vpn_2_main" {
  vpn_gateway_id      = "${module.vpc_2.vgw_id}"
  customer_gateway_id = "${aws_customer_gateway.vpc_transit_cgw.id}"
  type                = "ipsec.1"
  #static_routes_only  = true
}


# Generate the VPN Configuration
resource "null_resource" "generate_vpc_2_conf" {
  triggers {
    configuration = "${aws_vpn_connection.vpn_2_main.customer_gateway_configuration}"
    "test@"="test@"
  }



  provisioner "local-exec" {
    command = "echo '${aws_vpn_connection.vpn_2_main.customer_gateway_configuration}' > vpc-2-vpn-config.vpn.xml"
  }

  #/ ! \ sed added to Change the name of the interfaces to not use the same ones as the vpc-1
  #And chaneg the ipsec group
  # | sed -e 's/vti0/vti2/p' -e 's/vti1/vti3/p' -e 's/AWS/AWS2/p'
  provisioner "local-exec" {
    command = "python ../tools/transform-vpn-xml-to-vyatta.py vpc-2-vpn-config.vpn.xml ../tools/vyatta.xsl | sed -e 's/vti0/vti2/p' -e 's/vti1/vti3/p' > vpc-2-vpn-config.vyatta"
  }



  provisioner "local-exec" {
    command = "python ../tools/vyos_config.py vpc-2-vpn-config.vyatta ${aws_instance.vyos_instance.private_ip} ${module.vpc_2.vpc_cidr_block} ${cidrhost(module.vpc_2.vpc_cidr_block, 1)} > ../vpn-generated-configurations/vpc-2-vpn-config.vyos"
  }

  provisioner "local-exec" {
    command = "rm vpc-2-vpn-config.vpn.xml && rm vpc-2-vpn-config.vyatta"
  }

}
