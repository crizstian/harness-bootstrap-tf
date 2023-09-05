variable "harness_platform_account_id" {}
variable "harness_platform_api_key" {}

# Harness Platform Entities
variable "harness_platform_organizations" {
  description = "Harness Organizations to be created in the given Harness account"
  default     = {}
}
variable "harness_platform_projects" {
  description = "Harness Projects to be created in the given Harness account"
  default     = {}
}
variable "harness_resources_tags" {
  description = "Harness tags to be applied to all resources"
  default     = []
  type        = list(string)
}
variable "harness_platform_templates" {
  description = "Harness templates to be applied"
  default     = {}
}
variable "harness_platform_environments" {
  description = "Harness templates to be applied"
  default     = {}
}
variable "harness_platform_infrastructures" {
  description = "Harness templates to be applied"
  default     = {}
}
