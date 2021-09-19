pipeline {
  agent any
  stages {
    stage('terraform') {
      }
      steps {
        withAWS(credentials: 'epuerta-challenge', region: 'us-east-2')
        dir('infra/app') {
            sh 'terraform init'
            sh 'terraform validate'
            sh 'terraform workspace dev'
            sh 'terraform apply --auto-approve'
            sh 'terraform output -json'
        }
      }
    }

    stage('ansible') {
      steps {
        sh 'ls -la '
      }
    }

    stage('postbuild') {
      steps {
        echo 'postbuild'
      }
    }

  }
}