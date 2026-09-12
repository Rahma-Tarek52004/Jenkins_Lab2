
pipeline {

    agent any

    parameters {
        choice(
            name: 'TF_WORKSPACE',
            choices: ['dev', 'stg', 'prod'],
            description: 'Select Terraform workspace'
        )
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Select Workspace') {
            steps {
                sh '''
                    unset TF_WORKSPACE
                    terraform workspace select "${TF_WORKSPACE}"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    unset TF_WORKSPACE

                    terraform plan \
                    -var-file="${TF_WORKSPACE}.tfvars" \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                script {
                    def decision = input(
                        message: "Approve Terraform Apply for ${TF_WORKSPACE}?",
                        parameters: [
                            choice(
                                name: 'DECISION',
                                choices: ['Approve', 'Deny'],
                                description: 'Choose whether to apply the Terraform plan'
                            )
                        ]
                    )

                    if (decision == 'Deny') {
                        error(
                            "Terraform Apply denied for workspace ${TF_WORKSPACE}."
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    unset TF_WORKSPACE
                    terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    post {

        success {
            echo "Terraform pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER} completed successfully for workspace ${TF_WORKSPACE}."
        }

        failure {
            emailext(
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
Terraform pipeline failed.

Pipeline: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Workspace: ${TF_WORKSPACE}

Please check the Jenkins console log for the failure.

Build URL:
${env.BUILD_URL}
                """,
                to: 'rahmatarek52004@gmail.com',
                attachLog: true
            )
        }
    }
}
```

### ⚠️ One correction

Actually, there's an important problem with the code above: `unset TF_WORKSPACE` removes the variable, so `${TF_WORKSPACE}` would also become empty **inside the shell**.

Therefore, let's do it properly by copying the Jenkins parameter to another shell variable first.

**Use this final version instead:**

```groovy
pipeline {

    agent any

    parameters {
        choice(
            name: 'TF_WORKSPACE',
            choices: ['dev', 'stg', 'prod'],
            description: 'Select Terraform workspace'
        )
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Select Workspace') {
            steps {
                sh '''
                    SELECTED_WORKSPACE="${TF_WORKSPACE}"

                    unset TF_WORKSPACE

                    terraform workspace select "${SELECTED_WORKSPACE}"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    SELECTED_WORKSPACE="${TF_WORKSPACE}"

                    unset TF_WORKSPACE

                    terraform plan \
                    -var-file="${SELECTED_WORKSPACE}.tfvars" \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                script {
                    def decision = input(
                        message: "Approve Terraform Apply for ${TF_WORKSPACE}?",
                        parameters: [
                            choice(
                                name: 'DECISION',
                                choices: ['Approve', 'Deny'],
                                description: 'Choose whether to apply the Terraform plan'
                            )
                        ]
                    )

                    if (decision == 'Deny') {
                        error(
                            "Terraform Apply denied for workspace ${TF_WORKSPACE}."
                        )
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    unset TF_WORKSPACE

                    terraform apply -auto-approve tfplan
                '''
            }
        }
    }

    post {

        success {
            echo "Terraform pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER} completed successfully for workspace ${TF_WORKSPACE}."
        }

        failure {
            emailext(
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
Terraform pipeline failed.

Pipeline: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Workspace: ${TF_WORKSPACE}

Please check the Jenkins console log for the failure.

Build URL:
${env.BUILD_URL}
                """,
                to: 'rahmatarek52004@gmail.com',
                attachLog: true
            )
        }
    }
}



