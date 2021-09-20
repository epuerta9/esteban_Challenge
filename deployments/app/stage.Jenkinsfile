pipeline {
  agent any
  stages {
    stage('terraform') {
      steps {
        withAWS(credentials: 'epuerta-challenge', region: 'us-east-2'){
            dir('infra/app') {
                sh 'terraform init'
                sh 'terraform validate'
                sh 'if [[ ! -z terraform workspace list | grep stage ]];then terraform workspace new stage fi;'
                sh 'terraform workspace select stage'
                sh 'terraform apply -var-file=stage.tfvars --auto-approve'
                sh 'terraform output -json > ../ansible/tf_output.json'
            }
        }
      }
    }

  }
}