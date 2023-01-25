template:
  name: Terraform STO
  identifier: "${identifier}"
  versionLabel: "${version}"
  type: Stage
  tags: {}
  spec:
    type: CI
    spec:
      cloneCodebase: true
      infrastructure:
        type: KubernetesDirect
        spec:
          connectorRef: <+stage.variables.k8s_connector_ref>
          namespace: harness-delegate-ng
          automountServiceAccountToken: true
          nodeSelector: {}
          os: Linux
      execution:
        steps:
          - stepGroup:
              name: Terraform Scan
              identifier: Terraform_Scan
              steps:
                - parallel:
                    - step:
                        type: Run
                        name: AquaSec
                        identifier: aquasecurity_tfsec
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: aquasec/tfsec-alpine
                          shell: Sh
                          command: |-
                            ls -la
                            tfsec --out tfsecout.json --format json /harness
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                    - step:
                        type: Run
                        name: Checkov
                        identifier: Checkov
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: bridgecrew/checkov
                          shell: Sh
                          command: |
                            sleep 2
                            ls -la
                            checkov --skip-path tfscan.json --skip-path tfsecout.json --output json --compact --output-file-path checkov -d .
                          privileged: false
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                    - step:
                        type: Run
                        name: Terrascan
                        identifier: Terrascan
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: tenable/terrascan
                          shell: Sh
                          command: |
                            sleep 4
                            ls -la
                            terrascan scan -o json > tfscan.json
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
          - stepGroup:
              name: STO Process
              identifier: STO_Process
              steps:
                - parallel:
                    - step:
                        type: Run
                        name: Checkov Ingest
                        identifier: Checkov_Ingest
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: ubuntu
                          shell: Sh
                          command: |
                            apt-get update
                            apt-get install -y jq

                            ls -la

                            ls -la checkov

                            arr="[]"
                            i=0
                            jq -c '.[]' checkov/results_json.json | while read f; do

                                for row in $(echo "$f" | jq -r '.results.failed_checks[] | @base64'); do

                                    id=$(echo "$row" | base64 --decode | jq .check_id | sed 's/\"//g')
                                    bc_id=$(echo "$row" | base64 --decode | jq .bc_check_id | sed 's/\"//g')
                                    issueName=$(echo "$row" | base64 --decode | jq .check_name | sed 's/\"//g')
                                    issueDescription=$(echo "$row" | base64 --decode | jq .description | sed 's/\"//g')
                                    fileName=$(echo "$row" | base64 --decode | jq .file_path | sed 's/\"//g')
                                    remediationSteps=$(echo "$row" | base64 --decode | jq .check_class | sed 's/\"//g')
                                    risk=$(echo "$row" | base64 --decode | jq .guideline | sed 's/\"//g')
                                    severity=5
                                    status=$(echo "$row" | base64 --decode | jq .check_result.result | sed 's/\"//g')
                                    cvss=$(echo "$row" | base64 --decode | jq .check_id | sed 's/\"//g')
                                    
                                    issueType=$(echo $f | jq .check_type | sed 's/\"//g') 
                                    lineNumber=$(echo "$row" | base64 --decode | jq .file_line_range[0] | sed 's/\"//g')
                                    product=$(echo "$row" | base64 --decode | jq .resource | sed 's/\"//g')

                                    element=$(jq -n '{scanTool: $scanTool,issueName: $issueName,issueDescription: $issueDescription,fileName: $fileName,remediationSteps: $remediationSteps,risk: $risk,severity: $severity|tonumber,status: $status,issueType: $issueType,lineNumber: $lineNumber,product: $product,referenceIdentifiers: $referenceIdentifiers}' \
                                        --arg scanTool "checkov" \
                                        --arg issueName "$issueName" \
                                        --arg issueDescription "$issueDescription" \
                                        --arg fileName "$fileName" \
                                        --arg remediationSteps "$remediationSteps" \
                                        --arg risk $risk" "\
                                        --arg severity $severity \
                                        --arg status "$status" \
                                        --arg issueType "$issueType" \
                                        --arg lineNumber "$lineNumber" \
                                        --arg product "$product" \
                                        --argjson referenceIdentifiers "[{\"type\":\"CKV\", \"id\":"$i"}]" \
                                        '$ARGS.named'
                                    )

                                    a=$(jq -n \
                                        --argjson temp "[$element]" \
                                        --argjson issues "$arr" \
                                        '$ARGS.named'
                                    )
                                    
                                    # echo $a | jq '.'

                                    arr=$(echo $a | jq '.temp + .issues')

                                    echo $arr | jq . > issues.json

                                    i=$(( $i + 1 ))
                                done

                            done

                            issues=$(cat issues.json | jq '.')

                            jq -n \
                                --argjson meta "{ \"key\":[\"issueName\"], \"author\":\"Checkov\" }" \
                                --argjson issues "$issues" \
                                '$ARGS.named' \
                                > checkov.json

                            #cat checkov.json | jq .

                            cp checkov.json /shared/customer_artifacts
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                        timeout: 5m
                    - step:
                        type: Run
                        name: Terrascan Ingest
                        identifier: Terrascan_Ingest
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: alpine
                          shell: Sh
                          command: |
                            apk add jq

                            cat tfscan.json

                            arr="[]"
                            # 
                            i=1
                            jq -c '.results.violations[]' tfscan.json | while read f; do

                                s=5
                                sev=$(echo $f | jq .severity | sed 's/\"//g')

                                if [ "$sev" = "LOW" ]; then
                                    s=3
                                elif [ "$sev" = "MEDIUM" ]; then
                                    s=5
                                elif [ "$sev" = "HIGH" ]; then
                                    s=10
                                fi
                                    # echo "$row" | base64 --decode | jq .check_id

                                    id=$(echo $f | jq .rule_id | sed 's/\"//g')
                                    issueName=$(echo $f | jq .rule_name | sed 's/\"//g')
                                    issueDescription=$(echo $f | jq .description | sed 's/\"//g')
                                    fileName=$(echo $f | jq .file | sed 's/\"//g')
                                    remediationSteps=$(echo $f | jq .category | sed 's/\"//g')
                                    risk=$(echo $f | jq .severity | sed 's/\"//g')
                                    severity=$s
                                    status=$(echo $f | jq .severity | sed 's/\"//g')
                                    cvss=$(echo $f | jq .rule_id | sed 's/\"//g')
                                    
                                    issueType=$(echo $f | jq .resource_name | sed 's/\"//g')
                                    lineNumber=$(echo $f | jq .line | sed 's/\"//g')
                                    product=$(echo $f | jq .resource_type | sed 's/\"//g')

                                    element=$(jq -n '{scanTool: $scanTool,issueName: $issueName,issueDescription: $issueDescription,fileName: $fileName,remediationSteps: $remediationSteps,risk: $risk,severity: $severity|tonumber,status: $status,issueType: $issueType,lineNumber: $lineNumber,product: $product,referenceIdentifiers: $referenceIdentifiers}' \
                                        --arg scanTool "terrascan" \
                                        --arg issueName "$issueName" \
                                        --arg issueDescription "$issueDescription" \
                                        --arg fileName "$fileName" \
                                        --arg remediationSteps "$remediationSteps" \
                                        --arg risk $risk" "\
                                        --arg severity $severity \
                                        --arg status "$status" \
                                        --arg cvss "$cvss" \
                                        --arg issueType "$issueType" \
                                        --arg lineNumber "$lineNumber" \
                                        --arg product "$product" \
                                        --argjson referenceIdentifiers "[{\"type\":\"CKV\", \"id\":\"$i\"}]" \
                                        '$ARGS.named'
                                    )

                                    a=$(jq -n \
                                        --argjson temp "[$element]" \
                                        --argjson issues "$arr" \
                                        '$ARGS.named'
                                    )
                                    
                                    # echo $a | jq '.'

                                    arr=$(echo $a | jq '.temp + .issues')

                                    echo $arr | jq . > issues.json

                                    i=$(( $i + 1 ))
                            done

                            issues=$(cat issues.json | jq '.')

                            jq -n \
                                --argjson meta "{ \"key\":[\"issueName\"], \"author\":\"Terrascan\" }" \
                                --argjson issues "$issues" \
                                '$ARGS.named' \
                                > scan.json

                            cat scan.json | jq .

                            cp scan.json /shared/customer_artifacts
                        timeout: 5m
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                    - step:
                        type: Run
                        name: Aquasec Ingest
                        identifier: Aquasec_Ingest
                        spec:
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: alpine
                          shell: Sh
                          command: |
                            apk add jq

                            cat tfsecout.json

                            arr="[]"
                            # 
                            i=1
                            jq -c '.results[]' tfsecout.json | while read f; do

                                s=5
                                sev=$(echo $f | jq .severity | sed 's/\"//g')

                                if [ "$sev" = "LOW" ]; then
                                    s=3
                                elif [ "$sev" = "MEDIUM" ]; then
                                    s=5
                                elif [ "$sev" = "HIGH" ]; then
                                    s=10
                                fi
                                    # echo "$row" | base64 --decode | jq .check_id

                                    id=$(echo $f | jq .rule_id | sed 's/\"//g')
                                    issueName=$(echo $f | jq .long_id | sed 's/\"//g')
                                    issueDescription=$(echo $f | jq .rule_description | sed 's/\"//g')
                                    fileName=$(echo $f | jq .location.filename | sed 's/\"//g')
                                    remediationSteps=$(echo $f | jq .resolution | sed 's/\"//g')
                                    risk=$(echo $f | jq .severity | sed 's/\"//g')
                                    severity=$s
                                    status=$(echo $f | jq .severity | sed 's/\"//g')
                                    cvss=$(echo $f | jq .rule_id | sed 's/\"//g')
                                    
                                    issueType=$(echo $f | jq .resource | sed 's/\"//g')
                                    lineNumber=$(echo $f | jq .location.start_line | sed 's/\"//g')
                                    product=$(echo $f | jq .rule_provider | sed 's/\"//g')

                                    element=$(jq -n '{scanTool: $scanTool,issueName: $issueName,issueDescription: $issueDescription,fileName: $fileName,remediationSteps: $remediationSteps,risk: $risk,severity: $severity|tonumber,status: $status,issueType: $issueType,lineNumber: $lineNumber,product: $product,referenceIdentifiers: $referenceIdentifiers}' \
                                        --arg scanTool "aquasec" \
                                        --arg issueName "$issueName" \
                                        --arg issueDescription "$issueDescription" \
                                        --arg fileName "$fileName" \
                                        --arg remediationSteps "$remediationSteps" \
                                        --arg risk $risk" "\
                                        --arg severity $severity \
                                        --arg status "$status" \
                                        --arg cvss "$cvss" \
                                        --arg issueType "$issueType" \
                                        --arg lineNumber "$lineNumber" \
                                        --arg product "$product" \
                                        --argjson referenceIdentifiers "[{\"type\":\"CKV\", \"id\":\"$i\"}]" \
                                        '$ARGS.named'
                                    )

                                    a=$(jq -n \
                                        --argjson temp "[$element]" \
                                        --argjson issues "$arr" \
                                        '$ARGS.named'
                                    )
                                    
                                    # echo $a | jq '.'

                                    arr=$(echo $a | jq '.temp + .issues')

                                    #echo $arr | jq . > issues.json

                                    i=$(( $i + 1 ))
                            done <<<$(find tmp -type f)

                            echo $arr | jq . > issues.json
                            issues=$(cat issues.json | jq '.')

                            jq -n \
                                --argjson meta "{ \"key\":[\"issueName\"], \"author\":\"Aquasec\" }" \
                                --argjson issues "$issues" \
                                '$ARGS.named' \
                                > tfsecscan.json

                            #cat tfsecscan.json | jq .

                            cp tfsecscan.json /shared/customer_artifacts
                        timeout: 5m
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                - parallel:
                    - step:
                        type: Security
                        name: STO TF Checkov
                        identifier: STO_TF_Checkov
                        spec:
                          privileged: true
                          settings:
                            policy_type: ingestionOnly
                            scan_type: repository
                            product_name: external
                            product_config_name: default
                            manual_upload_filename: checkov.json
                            customer_artifacts_path: /shared/customer_artifacts
                            repository_project: <+codebase.repoUrl>
                            repository_branch: main
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                    - step:
                        type: Security
                        name: STO TF Terrascan
                        identifier: STO_TF_Terrascan
                        spec:
                          privileged: true
                          settings:
                            policy_type: ingestionOnly
                            scan_type: repository
                            product_name: external
                            product_config_name: default
                            manual_upload_filename: scan.json
                            customer_artifacts_path: /shared/customer_artifacts
                            repository_project: <+codebase.repoUrl>
                            repository_branch: main
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
                    - step:
                        type: Security
                        name: STO TF Aquasec
                        identifier: STO_TF_Aquasec
                        spec:
                          privileged: true
                          settings:
                            policy_type: ingestionOnly
                            scan_type: repository
                            product_name: external
                            product_config_name: default
                            manual_upload_filename: tfsecscan.json
                            customer_artifacts_path: /shared/customer_artifacts
                            repository_project: <+codebase.repoUrl>
                            repository_branch: main
                        failureStrategies:
                          - onFailure:
                              errors:
                                - AllErrors
                              action:
                                type: Ignore
      sharedPaths:
        - /var/run
        - /shared/customer_artifacts
    when:
      pipelineStatus: Success
    variables:
      - name: k8s_connector_ref
        type: String
        description: ""
        value: <+input>
      - name: docker_connector_ref
        type: String
        description: ""
        value: <+input>