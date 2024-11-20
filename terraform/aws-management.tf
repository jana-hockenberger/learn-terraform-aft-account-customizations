module "aws-management" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "reselling.aws.germany+precitec@pcg.io"
    AccountName               = "AWS Root Multi-Account Landing Zone"
    ManagedOrganizationalUnit = "Root"
    SSOUserEmail              = "reselling.aws.germany+precitec@pcg.io"
    SSOUserFirstName          = "AWS Control Tower"
    SSOUserLastName           = "Admin"
  }

  account_tags = {
    "Function" = "ControlTowerManagementAccount"

  }

  change_management_parameters = {
    change_requested_by = "Infrastructure"
    change_reason       = "Import Management Account in AFT"
  }

  account_customizations_name = "aws-management"
}

