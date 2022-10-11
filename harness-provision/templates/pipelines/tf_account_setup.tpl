pipeline:
  name: ${name}
  identifier: ${name}_${suffix}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  tags: {}
  stages:
    - stage:
        name: Provisioning
        identifier: Provisioning
        description: ""
        type: Custom
        spec:
          execution:
            steps:
              - stepGroup:
                  name: Terraform Run
                  identifier: Terraform_Run
                  steps:
                    - step:
                        type: TerraformPlan
                        name: TF Plan
                        identifier: TF_Plan
                        spec:
                          configuration:
                            command: Apply
                            workspace: <+stage.variables.tf_workspace>
                            configFiles:
                              store:
                                type: Github
                                spec:
                                  gitFetchType: Branch
                                  connectorRef: ${git_connector_ref}
                                  branch: <+stage.variables.tf_branch>
                                  folderPath: <+stage.variables.tf_folder>
                            secretManagerRef: harnessSecretManager
                            backendConfig:
                              type: Inline
                              spec:
                                content: |-
                                  tf_bucket               = "<+stage.variables.tf_bucket>"
                                  tf_key                  = "<+stage.variables.tf_key>"
                                  tf_region               = "<+stage.variables.tf_region>"
                            environmentVariables:
                              - name: GOOGLE_BACKEND_CREDENTIALS
                                value: <+stage.variables.tf_gcp_keys>
                                type: String
                            varFiles:
                              - varFile:
                                  type: Remote
                                  identifier: tf_remote_seed_lab
                                  spec:
                                    store:
                                      type: Github
                                      spec:
                                        gitFetchType: Branch
                                        repoName: ""
                                        branch: <+stage.variables.tf_branch>
                                        paths:
                                          - <+stage.variables.tf_remote_vars>
                                        connectorRef: ${git_connector_ref}
                              - varFile:
                                  identifier: vars
                                  spec:
                                    content: harness_platform_api_key = "<+stage.variables.harness_api_key>"
                                  type: Inline
                          provisionerIdentifier: <+stage.variables.tf_provision_identifier>
                        timeout: 10m
                        failureStrategies: []
                    - step:
                        type: HarnessApproval
                        name: Approve
                        identifier: Approve
                        spec:
                          approvalMessage: Please review the following information and approve the pipeline progression
                          includePipelineExecutionHistory: true
                          approvers:
                            userGroups:
                              - ${approver_ref}
                            minimumCount: 1
                            disallowPipelineExecutor: false
                          approverInputs: []
                        timeout: 1d
                    - parallel:
                        - step:
                            type: TerraformApply
                            name: TF Apply
                            identifier: TF_Apply
                            spec:
                              configuration:
                                type: InheritFromPlan
                              provisionerIdentifier: <+stage.variables.tf_provision_identifier>
                            timeout: 10m
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "apply"
                            failureStrategies: []
                        - step:
                            type: TerraformDestroy
                            name: TF Destroy
                            identifier: TF_Destroy
                            spec:
                              configuration:
                                type: InheritFromPlan
                              provisionerIdentifier: <+stage.variables.tf_provision_identifier>
                            timeout: 10m
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "destroy"
                            failureStrategies: []
                  failureStrategies: []
                  delegateSelectors:
                    - ${delegate_ref}
            rollbackSteps: []
          serviceDependencies: []
        tags: {}
        variables:
          - name: tf_provision_identifier
            type: String
            description: ""
            value: <+input>
          - name: tf_branch
            type: String
            description: ""
            value: <+input>
          - name: tf_folder
            type: String
            description: ""
            value: <+input>
          - name: tf_workspace
            type: String
            description: ""
            value: <+input>
          - name: tf_remote_vars
            type: String
            description: ""
            value: <+input>
          - name: harness_api_key
            type: Secret
            description: ""
            value: account.${workspace}_harness_platform_api_key
          - name: tf_action
            type: String
            description: ""
            value: <+input>
          - name: tf_bucket
            type: String
            description: ""
            value: <+input>
          - name: tf_key
            type: String
            description: ""
            value: <+input>
          - name: tf_region
            type: Secret
            description: ""
            value: <+input>
          - name: tf_access_key
            type: Secret
            description: ""
            value: account.${workspace}_AWS_ACCESS_KEY_ID
          - name: tf_secret_key
            type: Secret
            description: ""
            value: account.${workspace}_AWS_SECRET_ACCESS_KEY