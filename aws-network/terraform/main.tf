resource "aws_vpc" "main" {
  cidr_block       = "10.200.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "egress-vpc"
  }
}

resource "aws_ec2_transit_gateway" "central_tgw" {
  description = "Central Transit Gateway"
  
  tags = {
    Name = "CentralTransitGateway"
  }
}
