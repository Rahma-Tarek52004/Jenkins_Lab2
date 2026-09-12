pipeline {

    agent any

    parameters {
        choice(
            name: 'WORKSPACE_NAME',
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
                sh 'terraform workspace select ${WORKSPACE_NAME}'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan \
                    -var-file="${WORKSPACE_NAME}.tfvars" \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                script {
                    def decision = input(
                        message: "Approve Terraform Apply for ${WORKSPACE_NAME}?",
                        parameters: [
                            choice(
                                name: 'DECISION',
                                choices: ['Approve', 'Deny'],
                                description: 'Choose whether to apply the Terraform plan'
                            )
                        ]
                    )

                    if (decision == 'Deny') {
                        error("Terraform Apply denied for workspace ${WORKSPACE_NAME}.")
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {

        success {
            echo "Terraform pipeline ${env.JOB_NAME} #${env.BUILD_NUMBER} completed successfully for workspace ${WORKSPACE_NAME}."
        }

        failure {
            emailext(
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
Terraform pipeline failed.

Pipeline: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Workspace: ${WORKSPACE_NAME}

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
