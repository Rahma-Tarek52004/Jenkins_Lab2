
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
                sh 'terraform workspace select ${TF_WORKSPACE}'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan \
                    -var-file="${TF_WORKSPACE}.tfvars" \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: "Approve Terraform Apply for ${TF_WORKSPACE}?",
                    ok: "Approve"
                )
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

