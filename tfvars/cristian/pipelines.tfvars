harness_platform_pipelines = {
  harness_seed_setup = {
    enable      = true
    description = "Pipeline generated by terraform harness provider"
    custom_template = {
      pipeline = {
        file          = "templates/pipelines/tf_account_setup.tpl"
        craft_request = false
        vars = {
          approver_ref = "account.SE_Admin"
          delegate_ref = "cristian-delegate-tf"
        }
      }
      inputset = {
        apply = {
          file          = "templates/inputsets/tf_account_setup_inputset_apply.tpl"
          enable        = true
          craft_request = false
          description   = "Inputset generated by terraform harness provider"
          vars = {
            tf_provision_identifier = "tf_devsecops"
            tf_folder               = "harness-provision"
            tf_backend_bucket       = "crizstian-terraform"
            tf_backend_prefix       = "harness-cristian-tf"
            tf_workspace            = "<+trigger.sourceBranch>"
            tf_account_vars         = "tfvars/<+trigger.sourceBranch>/account.tfvars"
            tf_connectors_vars      = "tfvars/<+trigger.sourceBranch>/connectors.tfvars"
            tf_delegates_vars       = "tfvars/<+trigger.sourceBranch>/delegates.tfvars"
            tf_pipelines_vars       = "tfvars/<+trigger.sourceBranch>/pipelines.tfvars"
          }
        }
      }
    }
  }
  tf_account_setup = {
    enable      = true
    description = "Pipeline generated by terraform harness provider"
    custom_template = {
      pipeline = {
        file          = "templates/pipelines/tf_account_setup.tpl"
        craft_request = false
        vars = {
          approver_ref  = "account.SE_Admin"
          delegate_ref  = "cristian-delegate-tf"
          git_connector = "devsecops"
        }
      }
      inputset = {
        apply = {
          file          = "templates/inputsets/tf_account_setup_inputset_apply.tpl"
          enable        = true
          craft_request = false
          description   = "Inputset generated by terraform harness provider"
          vars = {
            tf_provision_identifier = "tf_devsecops"
            tf_folder               = "harness-provision"
            tf_backend_bucket       = "crizstian-terraform"
            tf_backend_prefix       = "harness-cristian-tf"
            tf_workspace            = "<+trigger.sourceBranch>"
            tf_account_vars         = "tfvars/<+trigger.sourceBranch>/account.tfvars"
            tf_connectors_vars      = "tfvars/<+trigger.sourceBranch>/connectors.tfvars"
            tf_delegates_vars       = "tfvars/<+trigger.sourceBranch>/delegates.tfvars"
            tf_pipelines_vars       = "tfvars/<+trigger.sourceBranch>/pipelines.tfvars"
          }
        }
      }
    }
  }
  delegate_init = {
    enable      = true
    description = "Pipeline generated by terraform harness provider"
    custom_template = {
      pipeline = {
        file          = "templates/pipelines/delegate_init.tpl"
        craft_request = false
        vars = {
          git_connector = "devsecops"
        }
      }
    }
  }
}
