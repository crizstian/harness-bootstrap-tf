harness_opa_policies = {
  approval_required_test = {
    name        = "[Shared Services] Pipeline - Approval Required Policy"
    enable      = true
    description = "Policy Set generated by terraform harness provider"
    file        = "templates/shared_services/policies/platform/approval-required.rego"
  }
}
