harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"
organization_prefix         = "cristian_lab_devsecops_org"

remote_state = {
  enable    = true
  backend   = "gcs"
  workspace = "shared_services"
  config = {
    bucket = "crizstian-terraform"
    prefix = "cristian_lab_devsecops_org"
  }
}

harness_platform_organizations = {
  "cristian_lab_devsecops_org" = {
    enable        = true
    short_name    = "devsecops"
    description   = "Organization generated by terraform harness provider"
    tags          = ["owner: devsecops"]
    git_repo_name = "harness_bootstrap_tf"
    delegate_ref  = "devsecops-delegate-tf"
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
