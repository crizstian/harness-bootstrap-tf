# Harness Platform variables
variable "harness_platform_api_key" {
  type      = string
  sensitive = true
}
variable "harness_platform_account_id" {
  type = string
}
variable "harness_platform_organizations" {
  type    = map(any)
  default = {}
}
variable "harness_platform_projects" {
  type    = map(any)
  default = {}
}
# Harness Platform Delegate variables
variable "harness_platform_delegates" {
  type    = any
  default = {}
}
# Harness Platform Connectors variables
variable "harness_platform_github_connectors" {
  #type    = map(any)
  default = {}
}
variable "harness_platform_docker_connectors" {
  type    = map(any)
  default = {}
}
variable "harness_platform_aws_connectors" {
  # type    = map(any)
  default = {}
}
variable "harness_platform_gcp_connectors" {
  # type    = map(any)
  default = {}
}
variable "harness_platform_gitlab_connectors" {
  # type    = map(any)
  default = {}
}
# Harness Platform Pipeline variables
variable "harness_platform_pipelines" {
  #type    = map(any)
  default = {}
}
variable "harness_platform_inputsets" {
  type    = map(any)
  default = {}
}
variable "harness_platform_templates" {
  description = "Harness templates to be generated"
  default     = {}
}
# Harness Platform Policies variables
variable "harness_opa_policies" {
  #type    = map(any)
  default = {}
}
variable "harness_policyset_api_endpoint" {
  type    = string
  default = "https://app.harness.io/gateway/pm/api/v1/policysets"
}
# Other variables
variable "organization_prefix" {
  type    = string
  default = ""
}
variable "github_details" {
  default = {}
}
variable "remote_state" {
  # type    = map(any)
  default = {
    enable    = false
    backend   = ""
    workspace = ""
    config = {
      bucket = ""
      prefix = ""
    }
  }
}

