# GITHUB CONNECTORS
harness_platform_github_connectors = {
  devsecops = {
    id              = "account.devsecops_github_connector_ar6o"
    enable          = false
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
  infrateam = {
    id              = "account.infrateam_github_connector_ar6o"
    enable          = false
    description     = "Connector generated by terraform harness provider"
    connection_type = "Repo"
    url             = "https://github.com/crizstian/harness-infrateam-tf"
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
  test_demo = {
    enable          = false
    description     = "Connector generated by terraform harness provider"
    connection_type = "Repo"
    url             = "https://github.com/crizstian/harness-infrateam-tf"
    org_id          = "cristian-lab-infrateam-org"
    project_id      = "seed_pipeline"
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

# DOCKER CONNECTORS
harness_platform_docker_connectors = {
  devsecops = {
    enable             = true
    description        = "Connector generated by terraform harness provider"
    type               = "DockerHub"
    url                = "https://index.docker.io/v2/"
    delegate_selectors = ["cristian-delegate-tf"]
    credentials = {
      username        = "crizstian"
      password_ref_id = "account.crizstian_docker_token"
    }
  }
  infrateam = {
    enable             = true
    description        = "Connector generated by terraform harness provider"
    type               = "DockerHub"
    url                = "https://index.docker.io/v2/"
    delegate_selectors = ["cristian-delegate-tf"]
    credentials = {
      username        = "crizstian"
      password_ref_id = "account.crizstian_docker_token"
    }
  }
}

# AWS CONNECTORS
harness_platform_aws_connectors = {
  devsecops_account = {
    enable      = true
    description = "Connector generated by terraform harness provider"
    manual = {
      access_key_ref     = "account.cristian_aws_access_key"
      secret_key_ref     = "account.cristian_aws_secret_key"
      delegate_selectors = ["cristian-delegate-tf"]
    }
  }
}
# GCP CONNECTORS
harness_platform_gcp_connectors = {
  devsecops_account = {
    enable      = true
    description = "Connector generated by terraform harness provider"
    manual = {
      secret_key_ref     = "account.Cristian_GOOGLE_BACKEND_CREDENTIALS"
      delegate_selectors = ["cristian-delegate-tf"]
    }
  }
}
