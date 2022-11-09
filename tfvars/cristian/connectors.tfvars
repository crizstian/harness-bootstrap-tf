harness_platform_github_connectors = {
  devsecops_connector = {
    enable          = true
    description     = "Connector generated by terraform harness provider"
    connection_type = "Repo"
    url             = "https://github.com/crizstian/harness-bootstrap-tf"
    credentials = {
      http = {
        username     = "crizstian"
        token_ref_id = "account.crizstian_github_token"
      }
    }
    api_authentication = {
      token_ref_id = "account.crizstian_github_token"
    }
  }
}

harness_platform_docker_connectors = {
  devsecops_connector = {
    enable             = true
    description        = "Connector generated by terraform harness provider"
    type               = "DockerHub"
    url                = "https://hub.docker.com"
    delegate_selectors = ["cristian-delegate-tf"]
  }
}

harness_platform_aws_connectors = {
  se_account = {
    enable      = true
    description = "Connector generated by terraform harness provider"
    manual = {
      access_key_ref     = "account.cristian_aws_access_key"
      secret_key_ref     = "account.cristian_aws_secret_key"
      delegate_selectors = ["cristian-delegate-tf"]
    }
  }
}
