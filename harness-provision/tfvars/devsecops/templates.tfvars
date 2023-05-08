#Definicion de projectos ligados a una organizacion mediante la tag owner
harness_platform_templates = {
  "Terraform - Deployment" = {
    enable = true
    type   = "template-deployment"
    vars = {
      description = "Template generated by terraform harness provider"
      tags        = ["tecnologia: terraform"]
      yaml        = "./tfvars/devsecops/templates/template-deployment/terraform.tftpl"
      version     = "1"
      comments    = "terraform developed"
      is_stable   = true
    }
  }
  "TF Harness Account Setup" = {
    enable = true
    type   = "pipeline"
    vars = {
      description = "Template generated by terraform harness provider"
      tags        = ["tecnologia: terraform"]
      yaml        = "./tfvars/devsecops/templates/pipelines/terraform-harness-account-setup.tftpl"
      version     = "1"
      comments    = "terraform developed"
      is_stable   = true
    }
    template = {
      "template-deployment" = {
        template_name    = "Terraform - Deployment"
        template_version = "1"
        template_level   = "account"
      }
    }
    default_values = {
      GCS_BUCKET                 = "crizstian-terraform"
      GCS_PREFIX                 = "cristian_lab_account"
      HARNESS_ACCOUNT_ID         = "Io9SR1H7TtGBq9LVyJVB2w"
      HARNESS_PLATFORM_API_KEY   = "account.cristian_harness_token"
      GOOGLE_BACKEND_CREDENTIALS = "account.Cristian_GOOGLE_BACKEND_CREDENTIALS"
      TERRAFORM_REPO             = "harness-bootstrap-tf"
      TERRAFORM_FOLDER           = "harness-provision"
      TERRAFORM_BRANCH           = "main"
      DELEGATE_SELECTOR          = "terraform-delegate"
    }
  }
  "TF Harness Organization Setup" = {
    enable = true
    type   = "pipeline"
    vars = {
      description = "Template generated by terraform harness provider"
      tags        = ["tecnologia: terraform"]
      yaml        = "./tfvars/devsecops/templates/pipelines/terraform-harness-organization-setup.tftpl"
      version     = "1"
      comments    = "terraform developed"
      is_stable   = true
    }
    template = {
      "template-deployment" = {
        template_name    = "Terraform - Deployment"
        template_version = "1"
        template_level   = "account"
      }
    }
    default_values = {
      GCS_BUCKET                 = "crizstian-terraform"
      GCS_PREFIX                 = "cristian_lab_org"
      HARNESS_ACCOUNT_ID         = "Io9SR1H7TtGBq9LVyJVB2w"
      HARNESS_PLATFORM_API_KEY   = "account.cristian_harness_token"
      GOOGLE_BACKEND_CREDENTIALS = "account.Cristian_GOOGLE_BACKEND_CREDENTIALS"
      TERRAFORM_REPO             = "harness-infrateam-tf"
      TERRAFORM_FOLDER           = "harness-provision"
      TERRAFORM_BRANCH           = "main"
      DELEGATE_SELECTOR          = "terraform-delegate"
    }
  }
}
