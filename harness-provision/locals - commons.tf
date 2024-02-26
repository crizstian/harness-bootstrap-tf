# common vars
locals {
  common_tags = [
    "tf_workspace:${terraform.workspace}"
  ]
  suffix = random_string.suffix.id
}
