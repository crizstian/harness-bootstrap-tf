variable "harness_platform_account_id" {}
variable "harness_platform_organizations" {}
variable "harness_platform_api_key" {
  sensitive = true
}
variable "harness_platform_delegates" {
  default = {}
}
variable "harness_platform_github_connectors" {
  default = {}
}
variable "harness_platform_docker_connectors" {
  default = {}
}
variable "harness_platform_aws_connectors" {
  default = {}
}
variable "harness_platform_pipelines" {
  default = {}
}
variable "harness_platform_inputsets" {
  default = {}
}
# ---
variable "custom_templates" {
  default = {}
}
variable "organization_prefix" {
  default = ""
}

locals {
  common_schema_delegate = {
    description            = "Delegate deployed and generated by terraform harness provider"
    size                   = "SMALL"
    tags                   = ["owner: ${var.organization_prefix}"]
    clusterPermissionType  = "CLUSTER_ADMIN"
    customClusterNamespace = "harness-delegate-ng"
  }
  common_schema = {
    org_id     = module.bootstrap_harness_account.organization[var.organization_prefix].org_id
    project_id = module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id
    suffix     = module.bootstrap_harness_account.organization[var.organization_prefix].suffix
  }

  common_tags   = { tags = ["owner: ${var.organization_prefix}"] }
  git_prefix    = "_github_connector"
  seed_pipeline = var.harness_platform_pipelines["harness_seed_setup"]

  delegates         = { for type, delegates in var.harness_platform_delegates : type => { for key, value in delegates : key => merge(value, local.common_schema_delegate) } }
  docker_connectors = { for name, details in var.harness_platform_docker_connectors : name => merge(details, local.common_tags) if details.enable }
  aws_connectors    = { for name, details in var.harness_platform_aws_connectors : name => merge(details, local.common_tags) if details.enable }

  k8s_connectors = merge([for type, delegates in var.harness_platform_delegates : {
    for key, value in delegates : key => merge(
      value,
      local.common_tags,
      {
        description        = "K8s Connector generated by terraform harness provider"
        delegate_selectors = [key]
      }
    )
    } if type == "k8s"
  ]...)

  github_connectors = { for name, details in var.harness_platform_github_connectors : name => merge(
    details,
    local.common_tags,
    {
      validation_repo = details.connection_type == "Repo" ? "" : details.validation_repo
      org_id          = details.connection_type == "Repo" ? module.bootstrap_harness_account.organization[var.organization_prefix].org_id : try(details.org_id, "")
      project_id      = details.connection_type == "Repo" ? module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id : try(details.project_id, "")
      credentials = {
        http = {
          username     = details.credentials.http.username
          token_ref_id = try(details.credentials.http.token_ref_id, "")
        }
      }
      api_authentication = {
        token_ref = try(details.credentials.http.token_ref_id, "")
      }
  }) if details.enable }

  seed_pipelines = { for org, values in var.harness_platform_organizations : org => {
    pipeline = merge(
      { for key, value in local.seed_pipeline : key => value if key != "custom_template" },
      local.seed_pipeline.custom_template.pipeline,
      {
        vars = merge(
          local.seed_pipeline.custom_template.pipeline.vars,
          {
            org_id                  = module.bootstrap_harness_account.organization[org].org_id
            project_id              = module.bootstrap_harness_account.organization[org].seed_project_id
            suffix                  = module.bootstrap_harness_account.organization[org].suffix
            tf_provision_identifier = "tf_${org}"
            tf_backend_prefix       = org
            git_connector_ref       = module.bootstrap_harness_connectors.connectors.github_connectors["${values.short_name}${local.git_prefix}"].identifier
          }
        )
    })
    inputset = { for input, details in try(local.seed_pipeline.custom_template.inputset, {}) : input => merge(details) if details.enable }
    }
  }

  pipelines = { for pipe, values in var.harness_platform_pipelines : pipe => {
    pipeline = merge(
      { for key, value in values : key => value if key != "custom_template" },
      values.custom_template.pipeline,
      {
        vars = merge(
          values.custom_template.pipeline.vars,
          local.common_schema,
          {
            git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors["${values.custom_template.pipeline.vars.git_connector}${local.git_prefix}"].identifier
            service_ref       = module.bootstrap_harness_delegates.delegate_init.service_ref
            environment_ref   = module.bootstrap_harness_delegates.delegate_init.environment_ref
          }
        )
      }
    )
    inputset = { for input, details in try(values.custom_template.inputset, {}) : input => merge(details) if details.enable }
    } if pipe != "harness_seed_setup"
  }

  # pipelines = { for key, details in var.harness_platform_pipelines : key => merge(
  #   details,
  #   {
  #     custom_template = {
  #       pipeline = merge(
  #         details.custom_template.pipeline,
  #         {
  #           vars = merge(
  #             details.custom_template.pipeline.vars,
  #             local.common_schema,
  #             {
  #               # tf_account_setup
  #               git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors["${details.custom_template.pipeline.vars.git_connector}${local.git_prefix}"].identifier

  #               # delegate_init
  #               service_ref     = module.bootstrap_harness_delegates.delegate_init.service_ref
  #               environment_ref = module.bootstrap_harness_delegates.delegate_init.environment_ref
  #             }
  #           )
  #       })
  #       inputset = try(details.custom_template.inputset, {})
  #     }
  #   }) if can(details.custom_template.pipeline) && key != "harness_seed_setup"
  # }
}
