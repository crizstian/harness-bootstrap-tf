# common vars
locals {

  delegate_count = [for type, delegates in var.harness_platform_delegates : { for key, value in delegates : key => value if value.enable && type == "k8s" }]

  delegate_init_service = {
    enable     = length(local.delegate_count) > 0
    org_id     = try(local.common_schema.org_id, "")
    project_id = try(local.common_schema.project_id, "")
  }

  delegate_account_ref = var.remote_state.enable ? element(keys(local.remote_state.delegates.account), 0) : ""
  delegate_selectors   = var.remote_state.enable ? [local.delegate_account_ref] : [var.harness_platform_organizations[var.organization_prefix].delegate_ref]
  delegate_ref         = try(var.harness_platform_organizations[var.organization_prefix].delegate_ref, local.delegate_account_ref)
}
