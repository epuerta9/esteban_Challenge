pipeline {
  agent any
  stages {
    stage('terraform') {
      steps {
        withAWS(credentials: 'epuerta-challenge', region: 'us-east-2'){
            dir('infra/app') {
                sh 'terraform init'
                sh 'terraform validate'
                sh 'if [[ $(terraform workspace list | grep prod != *"prod"*) ]];then terraform workspace new prod; fi'
                sh 'terraform workspace select prod'
                sh 'terraform apply -var-file=prod.tfvars --auto-approve'
                sh 'terraform output -json > ../ansible/tf_output.json'
            }
        }
      }
    }

  }
}