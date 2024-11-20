# OU Definition

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = var.root_ou
}

resource "aws_organizations_organizational_unit" "qualified_workloads" {
  name      = "Qualified Workloads"
  parent_id = var.root_ou
}

resource "aws_organizations_organizational_unit" "sdlc" {
  name      = "SDLC"
  parent_id = var.root_ou
}


resource "aws_organizations_organizational_unit" "germany" {
  name      = "Germany"
  parent_id = aws_organizations_organizational_unit.qualified_workloads.id
}


resource "aws_organizations_organizational_unit" "usa" {
  name      = "USA"
  parent_id = aws_organizations_organizational_unit.qualified_workloads.id
}

resource "aws_organizations_organizational_unit" "china" {
  name      = "China"
  parent_id = aws_organizations_organizational_unit.qualified_workloads.id
}


variable "root_ou" {
  type        = string
  default     = "r-puch"
  description = "Root OU Id"
}