pipeline:
  name: ${name}
  identifier: ${identifier}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  tags: {}
  stages:
    - stage:
        name: Terraform STO
        identifier: Terraform_STO
        template:
          templateRef: ${template_id}
          versionLabel: ${template_version}
          templateInputs:
            type: CI
            variables:
              - name: k8s_connector_ref
                type: String
                value: <+input>
              - name: docker_connector_ref
                type: String
                value: <+input>
    - stage:
        name: Terraform Provisioning
        identifier: Provisioning
        description: ""
        type: Custom
        spec:
          execution:
            steps:
              - stepGroup:
                  name: Terraform Plan
                  identifier: Terraform_Plan
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
                                  repoName: <+stage.variables.tf_repo_name>
                                  branch: <+stage.variables.tf_branch>
                                  folderPath: <+stage.variables.tf_folder>
                              moduleSource:
                                useConnectorCredentials: true
                            secretManagerRef: account.harnessSecretManager
                            backendConfig:
                              type: Inline
                              spec:
                                content: |-
                                  bucket = "<+stage.variables.tf_backend_bucket>"
                                  prefix = "<+stage.variables.tf_backend_prefix>"
                            environmentVariables:
                              - name: HARNESS_ACCOUNT_ID
                                value: <+stage.variables.harness_account_id>
                                type: String
                              - name: HARNESS_PLATFORM_API_KEY
                                value: <+stage.variables.harness_api_key>
                                type: String
                              - name: HARNESS_ENDPOINT
                                value: <+stage.variables.harness_endpoint>
                                type: String
                              - name: GOOGLE_BACKEND_CREDENTIALS
                                value: <+stage.variables.tf_gcp_keys>
                                type: String
                              - name: GITHUB_TOKEN
                                value: <+stage.variables.github_token>
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
                                          - tfvars/<+stage.variables.tf_workspace>/account.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/connectors.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/delegates.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/pipelines.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/templates.tfvars
                                        connectorRef: ${git_connector_ref}
                              - varFile:
                                  identifier: vars
                                  spec:
                                    content: harness_platform_api_key = "<+stage.variables.harness_api_key>"
                                  type: Inline
                            exportTerraformPlanJson: true
                          provisionerIdentifier: <+stage.variables.tf_workspace>
                        timeout: 10m
                        failureStrategies: []
                    - step:
                        type: ShellScript
                        name: Export Plan
                        identifier: Export_Plan
                        spec:
                          shell: Bash
                          onDelegate: true
                          source:
                            type: Inline
                            spec:
                              script: tfplan=$(cat <+execution.steps.Terraform_Plan.steps.TF_Plan.plan.jsonFilePath>)
                          environmentVariables: []
                          outputVariables:
                            - name: tfplan
                              type: String
                              value: tfplan
                        timeout: 10m
                    - step:
                        type: Policy
                        name: Terraform Compliance Check
                        identifier: Terraform_Compliance_Check
                        spec:
                          policySets:
                            - account.Terraform_Compliance
                          type: Custom
                          policySpec:
                            payload: <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Export_Plan.output.outputVariables.tfplan>
                        timeout: 10m
                  failureStrategies: []
                  delegateSelectors:
                    - ${delegate_ref}
              - step:
                  type: HarnessApproval
                  name: Approve
                  identifier: Approve
                  spec:
                    approvalMessage: Please review the following information and approve the pipeline progression
                    includePipelineExecutionHistory: true
                    approvers:
                      userGroups:
                        - account.SE_Admin
                      minimumCount: 1
                      disallowPipelineExecutor: false
                    approverInputs: []
                  timeout: 1d
                  when:
                    stageStatus: Success
                    condition: <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Terraform_Compliance_Check.output.status> != "pass" && <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Terraform_Cost_Governance.output.status> != "pass"
                  failureStrategies: []
              - stepGroup:
                  name: Terraform Execution
                  identifier: Terraform_Deployment
                  steps:
                    - parallel:
                        - step:
                            type: TerraformApply
                            name: TF Apply
                            identifier: TF_Apply
                            spec:
                              configuration:
                                type: InheritFromPlan
                              provisionerIdentifier: <+stage.variables.tf_workspace>
                            timeout: 1h
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "apply"
                            failureStrategies: []
                        - step:
                            type: TerraformDestroy
                            name: TF Destroy
                            identifier: TF_D
                            spec:
                              provisionerIdentifier: <+stage.variables.tf_workspace>
                              configuration:
                                type: Inline
                                spec:
                                  workspace: <+stage.variables.tf_workspace>
                                  configFiles:
                                    store:
                                      spec:
                                        connectorRef: ${git_connector_ref}
                                        gitFetchType: Branch
                                        branch: <+stage.variables.tf_branch>
                                        folderPath: <+stage.variables.tf_folder>
                                      type: Github
                                    moduleSource:
                                      useConnectorCredentials: true
                                  backendConfig:
                                    type: Inline
                                    spec:
                                      content: |-
                                        bucket = "<+stage.variables.tf_backend_bucket>"
                                        prefix = "<+stage.variables.tf_backend_prefix>"
                                  environmentVariables:
                                    - name: HARNESS_ACCOUNT_ID
                                      value: <+stage.variables.harness_account_id>
                                      type: String
                                    - name: HARNESS_PLATFORM_API_KEY
                                      value: <+stage.variables.harness_api_key>
                                      type: String
                                    - name: HARNESS_ENDPOINT
                                      value: <+stage.variables.harness_endpoint>
                                      type: String
                                    - name: GOOGLE_BACKEND_CREDENTIALS
                                      value: <+stage.variables.tf_gcp_keys>
                                      type: String
                                    - name: GITHUB_TOKEN
                                      value: <+stage.variables.github_token>
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
                                                - tfvars/<+stage.variables.tf_workspace>/account.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/connectors.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/delegates.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/pipelines.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/templates.tfvars
                                              connectorRef: ${git_connector_ref}
                                    - varFile:
                                        identifier: vars
                                        spec:
                                          content: harness_platform_api_key = "<+stage.variables.harness_api_key>"
                                        type: Inline
                            timeout: 50m
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "destroy"
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Retry
                                    spec:
                                      retryCount: 1
                                      onRetryFailure:
                                        action:
                                          type: ManualIntervention
                                          spec:
                                            timeout: 30m
                                            onTimeout:
                                              action:
                                                type: Abort
                                      retryIntervals:
                                        - 1m
                    - step:
                        type: TerraformRollback
                        name: TF Rollback
                        identifier: TF_Rollback
                        spec:
                          provisionerIdentifier: <+stage.variables.tf_workspace>
                        timeout: 10m
                        when:
                          stageStatus: Failure
                        failureStrategies: []
                  failureStrategies: []
                  delegateSelectors:
                    - ${delegate_ref}
            rollbackSteps: []
        tags: {}
        failureStrategies: []
        variables:
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
          - name: tf_backend_bucket
            type: String
            description: ""
            value: <+input>
          - name: tf_backend_prefix
            type: String
            description: ""
            value: <+input>
          - name: tf_gcp_keys
            type: Secret
            description: ""
            value: account.Cristian_GOOGLE_BACKEND_CREDENTIALS
          - name: tf_action
            type: String
            description: ""
            value: <+input>
          - name: harness_api_key
            type: Secret
            description: ""
            value: account.cristian_harness_platform_api_key
          - name: harness_account_id
            type: String
            description: ""
            value: Io9SR1H7TtGBq9LVyJVB2w
          - name: harness_endpoint
            type: String
            description: ""
            value: https://app.harness.io/gateway
          - name: github_token
            type: Secret
            description: ""
            value: account.crizstian_github_token
  properties:
    ci:
      codebase:
        connectorRef: ${git_connector_ref}
        repoName: ${git_repo_ref}
        build: <+input>
