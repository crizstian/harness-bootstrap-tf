harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"
organization_prefix         = "cristian_lab_infrateam_org"

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
  "cristian_lab_infrateam_org" = {
    enable        = true
    short_name    = "infrateam"
    description   = "Organization generated by terraform harness provider"
    tags          = ["owner: infrateam"]
    git_repo_name = "harness-infrateam-tf"
  }
}
