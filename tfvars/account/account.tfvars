harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"
organization_prefix         = "cristian_account_lab"

remote_state = {
  enable    = false
  backend   = ""
  workspace = ""
  config = {
    bucket = ""
    prefix = ""
  }
}

harness_platform_organizations = {
  "cristian_account_lab" = {
    enable       = false
    short_name   = "cristian_account_lab"
    description  = "Organization generated by terraform harness provider"
    tags         = ["owner: cristian_account_lab"]
    git_repo     = "harness-bootstrap-tf"
    delegate_ref = "cristian-account-delegate-tf"
  }
}

harness_opa_policies = {
  harness_policies = {
    enable      = true
    description = "Policy Set generated by terraform harness provider"
    level       = "account"
    policies = {
      approval_required_test = {
        enable        = true
        file          = "templates/policies/harness/approval-required.rego"
        craft_request = true
      }
    }
  }
  terraform_policies = {
    enable      = true
    description = "Policy Set generated by terraform harness provider"
    level       = "organization"
    policies = {
      tags_required_test = {
        enable        = true
        file          = "templates/policies/terraform/tags-required.rego"
        craft_request = true
      }
      budget_allowed_test = {
        enable        = true
        file          = "templates/policies/terraform/budget-allowed.rego"
        craft_request = true
      }
    }
  }
}