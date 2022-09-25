inputSet:
  name: BCP Input
  tags: {}
  identifier: BCP_Input
  orgIdentifier: ${org_identifier}
  projectIdentifier: ${proj_identifier}
  pipeline:
    identifier: Harness_TF_BCP_Account_Setup
    template:
      templateInputs:
        stages:
          - stage:
              identifier: Provisioning
              type: Custom
              variables:
                - name: action
                  type: String
                  value: ""
                - name: repoName
                  type: String
                  value: harness-bcp-tf-devops
                - name: branch
                  type: String
                  value: main
                - name: folderPath
                  type: String
                  value: harness-bcp-bootstrap
                - name: provisioner_identifier
                  type: String
                  value: bcp_account_tf
                - name: tf_backend_username
                  type: String
                  value: admin
                - name: tf_backend_password
                  type: String
                  value: <+secrets.getValue("connector_crizstian_artifactory_token")>
                - name: tf_backend_url
                  type: String
                  value: http://artifactory--se-latam-demo.harness-demo.site.harness-demo.site.harness-demo.site/artifactory
                - name: tf_backend_repo
                  type: String
                  value: terraform
                - name: tf_backend_subpath
                  type: String
                  value: bcp_account_tf
                - name: harness_platform_api_key
                  type: String
                  value: <+secrets.getValue("harness_platform_api_key")>
                - name: harness_platform_account_id
                  type: String
                  value: <+secrets.getValue("harness_platform_account_id")>
