#Definicion de projectos ligados a una organizacion mediante la tag owner
harness_platform_templates = {
  "Terraform - Deployment" = {
    enable = true
    type   = "template-deployment"
    vars = {
      description = "Template generated by terraform harness provider"
      tags        = ["tecnologia: terraform"]
      yaml        = "./tfvars/devsecops/templates/custom/terraform.tftpl"
      version     = "1"
      comments    = "terraform developed"
      is_stable   = true
    }
  }
  "Terraform Harness Configuration Pipeline" = {
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
        type             = "template-deployment"
      }
      "sto" = {
        template_name    = "Terraform STO"
        template_version = "1"
        template_level   = "account"
        type             = "stage"
      }
    }
    connectors = {
      github = {
        GIT_CONNECTOR = "CRISTIAN_GITHUB"
      }
    }
    default_values = {
      HARNESS_ACCOUNT_ID         = "Io9SR1H7TtGBq9LVyJVB2w"
      HARNESS_PLATFORM_API_KEY   = "account.cristian_harness_sa"
      GOOGLE_BACKEND_CREDENTIALS = "account.Cristian_GOOGLE_BACKEND_CREDENTIALS"
      ENVIRONMENT_NAME           = "harness"
      DELEGATE_SELECTOR          = "cristian-se-delegate"
      GCS_BUCKET                 = "crizstian-terraform"
    }
  }
  "TF Harness Organization Setup" = {
    enable = false
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
        type             = "template-deployment"
      }
      "sto" = {
        template_name    = "Terraform STO"
        template_version = "1"
        template_level   = "account"
        type             = "stage"
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
      DELEGATE_SELECTOR          = "cristian-se-delegate"
    }
  }
  "Terraform STO" = {
    enable = true
    type   = "stage"
    vars = {
      description = "Template generated by terraform harness provider"
      tags        = ["tecnologia: terraform"]
      yaml        = "./tfvars/devsecops/templates/stage/terraform-sto.tftpl"
      version     = "1"
      comments    = "terraform developed"
      is_stable   = true
    }
  }
}
