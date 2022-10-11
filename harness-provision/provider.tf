provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_platform_account_id
  platform_api_key = var.harness_platform_api_key
}

provider "harness" {
  alias            = "provisioner"
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_platform_account_id
  platform_api_key = var.harness_platform_api_key
}

terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }

  #backend "gcs" {}
  backend "s3" {}
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}
