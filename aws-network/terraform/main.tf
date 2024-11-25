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

resource "aws_ram_resource_share" "tgw_share" {
  name = "CentralTransitGatewayShare"
  
  allow_external_principals = false

  tags = {
    Name = "CentralTransitGatewayShare"
  }
}

resource "aws_ram_resource_association" "tgw_association" {
  resource_arn       = aws_ec2_transit_gateway.central_tgw.arn
  
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

resource "aws_ram_principal_association" "org_association" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn

  principal = data.aws_organizations_organization.current.arn
}

data "aws_organizations_organization" "current" {}