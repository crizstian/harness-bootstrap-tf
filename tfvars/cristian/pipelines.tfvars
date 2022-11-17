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
            tf_folder         = "harness-provision"
            tf_backend_bucket = "crizstian-terraform"
            tf_workspace      = "<+stage.variables.tf_workspace>"
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
