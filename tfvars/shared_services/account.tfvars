harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"
organization_prefix         = "cristian_lab_shared_services_org"

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
  "cristian_lab_shared_services_org" = {
    enable       = true
    short_name   = "shared_services"
    description  = "Organization generated by terraform harness provider"
    tags         = ["owner: cristian_lab_shared_services_org"]
    git_repo     = "harness-bootstrap-tf"
    delegate_ref = "cristian-shared-services-lab"
  }
}

harness_opa_policies = {}
