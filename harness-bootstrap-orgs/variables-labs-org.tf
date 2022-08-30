variable "cristian_lab_org_projects" {
  default = {
    enable            = true
    organization_name = "cristian-lab-org"
    description       = "Organization generated by terraform harness provider"
    projects = {
      "Harness Cinemas Seed" = {
        enable      = true
        description = "Project generated by terraform harness provider"
      }
      "Harness Italika Seed" = {
        enable      = true
        description = "Project generated by terraform harness provider"
      }
    }
  }
}
