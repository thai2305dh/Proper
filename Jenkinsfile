pipeline {
    agent any

    parameters {
        choice(name: 'environment', choices: ['default', 'dev', 'stagging'], description: 'Workspace/environment file to use for deployment')
        choice(name: 'run', choices: ['plan -input=false -out tfplan', 'destroy --auto-approve'], description: 'Run plan or destroy')
        string(name: 'version', defaultValue: '', description: 'Version variable to pass to Terraform')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TF_IN_AUTOMATION      = '3'
    }

    stages {
        stage('Plan') {
            steps {
                script {
                    currentBuild.displayName = params.version
                }
                    sh 'terraform init -input=false'
//                     sh 'terraform workspace new ${environment}'
                    sh 'terraform workspace select ${environment}'
                    // sh "terraform plan -input=false -out tfplan -var 'version=${params.version}' --var-file=environments/${params.environment}.tfvars"
                    sh "terraform ${run} --var-file=environments/${params.environment}.tfvars"    
                    sh 'terraform show -no-color tfplan > tfplan.txt'          
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan.txt'
        }
    }
}
