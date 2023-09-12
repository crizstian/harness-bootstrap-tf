resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}

# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-structure?ref=refactor"
  suffix                         = random_string.suffix.id
  tags                           = local.common_tags
  harness_platform_organizations = var.harness_platform_organizations
  harness_platform_projects      = var.harness_platform_projects
}

# Creacion de Conectores
module "bootstrap_harness_connectors" {
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connector?ref=refactor"

  suffix        = random_string.suffix.id
  tags          = local.common_tags
  organizations = module.bootstrap_harness_account.organizations
  projects      = module.bootstrap_harness_account.projects

  harness_platform_github_connectors      = var.harness_platform_github_connectors
  harness_platform_gitlab_connectors      = var.harness_platform_gitlab_connectors
  harness_platform_docker_connectors      = var.harness_platform_docker_connectors
  harness_platform_service_now_connectors = var.harness_platform_service_now_connectors
  harness_platform_dynatrace_connectors   = var.harness_platform_dynatrace_connectors
  harness_platform_gcp_connectors         = var.harness_platform_gcp_connectors
  harness_platform_aws_connectors         = var.harness_platform_aws_connectors
  harness_platform_newrelic_connectors    = var.harness_platform_newrelic_connectors
  harness_platform_helm_connectors        = var.harness_platform_helm_connectors
  harness_platform_kubernetes_connectors  = var.harness_platform_kubernetes_connectors
}

# Creacion de Harness Templates
module "bootstrap_harness_templates" {
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-template?ref=refactor"
  suffix                     = random_string.suffix.id
  tags                       = local.common_tags
  organizations              = module.bootstrap_harness_account.organizations
  projects                   = module.bootstrap_harness_account.projects
  connectors                 = module.bootstrap_harness_connectors.all
  harness_platform_templates = var.harness_platform_templates
}

# Create Environments
module "bootstrap_harness_environments" {
  source                           = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-infrastructure?ref=refactor"
  suffix                           = random_string.suffix.id
  tags                             = local.common_tags
  organizations                    = module.bootstrap_harness_account.organizations
  projects                         = module.bootstrap_harness_account.projects
  templates                        = module.bootstrap_harness_templates.all
  connectors                       = module.bootstrap_harness_connectors.all
  harness_platform_environments    = var.harness_platform_environments
  harness_platform_infrastructures = var.harness_platform_infrastructures
}

/* # Create Policies
module "bootstrap_harness_policies" {
  source                       = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-policy?ref=refactor"
  suffix                       = random_string.suffix.id
  tags                         = local.common_tags
  organizations                = module.bootstrap_harness_account.organizations
  projects                     = module.bootstrap_harness_account.projects
  harness_platform_policies    = var.harness_platform_policies
  harness_platform_policy_sets = var.harness_platform_policy_sets
} */
