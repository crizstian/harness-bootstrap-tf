harness_platform_pipelines = {
  delegate_init = {
    components = {
      pipeline = {
        enable      = true
        description = "Pipeline generated by terraform harness provider"
        tags        = ["purpose: delegate_profiling"]
        file        = "templates/shared_services/pipelines/delegate_init.tpl"
        stages      = {}
        vars = {
          git_connector = "shared_services"
        }
      }
      inputset = {
        shared_services = {
          file          = "templates/shared_services/inputsets/delegate_init.tpl"
          enable        = true
          craft_request = false
          description   = "Inputset generated by terraform harness provider"
          vars = {
            enable_terraform = true
            enable_gcloud    = false
            os_linux_distro  = "centos"
            TF_VERSION       = "1.3.5"
          }
        }
      }
      trigger = {
        shared_services_lab = {
          file          = "templates/shared_services/triggers/delegate_init_cron.tpl"
          enable        = true
          craft_request = false
          description   = "Trgger generated by terraform harness provider"
          inputset_ref = {
            "shared_services" = true
          }
          vars = {}
        }
      }
    }
  }
}
