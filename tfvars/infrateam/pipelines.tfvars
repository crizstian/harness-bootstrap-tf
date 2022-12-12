harness_platform_pipelines = {
  harness_seed_setup = {
    enable      = true
    description = "Pipeline generated by terraform harness provider"
    tags        = ["purpose: seed_bootstrap"]
    custom_template = {
      pipeline = {
        file          = "templates/pipelines/tf_account_setup.tpl"
        craft_request = false
        vars = {
          approver_ref = "account.SE_Admin"
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
            tf_workspace      = "<+trigger.sourceBranch>"
          }
        }
      }
    }
  }
}