# common vars
locals {
  delegate_init_service = length(var.harness_platform_delegates) > 0 ? {
    enable     = local.enable_seed_pipeline
    org_id     = local.common_schema.org_id
    project_id = local.common_schema.project_id
    } : {
    enable     = false
    org_id     = ""
    project_id = ""
  }

  delegate_account_ref = var.remote_state.enable ? element(keys(local.remote_state.delegates.account), 0) : ""
  delegate_selectors   = var.remote_state.enable ? [local.delegate_account_ref] : [var.harness_platform_organizations[var.organization_prefix].delegate_ref]
  delegate_ref         = try(var.harness_platform_organizations[var.organization_prefix].delegate_ref, local.delegate_account_ref)
}