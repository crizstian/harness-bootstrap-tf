# github connectors
locals {
  github_connectors = { for key, value in var.harness_platform_github_connectors : key => merge(value, {
    org_id     = try(value.seed_connector, false) ? module.bootstrap_harness_account.organization[var.organization_prefix].org_id : ""
    project_id = try(value.seed_connector, false) ? module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id : ""
  }) }

  k8s_account_ref    = var.remote_state.enable ? local.remote_state.delegates.account[local.delegate_account_ref].k8s_connector.identifier : ""
  docker_account_ref = var.remote_state.enable ? local.remote_state.connectors.docker_connectors["cristian_account_lab"].identifier : ""
  github_account_ref = var.remote_state.enable ? local.remote_state.connectors.github_connectors["cristian_account_lab"].identifier : ""

  k8s_connector_ref    = try(module.bootstrap_harness_delegates.manifests["account"][local.delegate_ref].k8s_connector.identifier, local.k8s_account_ref)
  docker_connector_ref = try(module.bootstrap_harness_connectors.connectors.docker_connectors[local.organization_short_name].identifier, local.docker_account_ref)
  github_connector_ref = try(module.bootstrap_harness_connectors.connectors.github_connectors[local.organization_short_name].identifier, local.github_account_ref)
}
