output "harness" {
  value = module.bootstrap_harness_account
}
output "connectors" {
  value = module.bootstrap_harness_connectors
}
output "templates" {
  value = module.bootstrap_harness_templates
}
output "environments" {
  value = module.bootstrap_harness_environments
}
/* output "policies" {
  value = module.bootstrap_harness_policies
} */


output "roles" { value = module.bootstrap_harness_roles.roles }
output "users" { value = module.bootstrap_harness_users.users }
output "usergroups" { value = module.bootstrap_harness_usersgroups.usergroups }
output "service_accounts" { value = module.bootstrap_harness_service_accounts.service_accounts }
output "resource_groups" { value = module.bootstrap_harness_resource_groups.resource_groups }
