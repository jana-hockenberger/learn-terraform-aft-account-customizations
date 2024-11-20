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

variable "root_ou" {
  type        = string
  default     = "r-puch"
  description = "Root OU Id"
}