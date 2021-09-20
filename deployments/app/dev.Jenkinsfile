pipeline {
  agent any
  stages {
    stage('terraform') {
      steps {
        withAWS(credentials: 'epuerta-challenge', region: 'us-east-2'){
            dir('infra/app') {
                sh 'terraform init'
                sh 'terraform validate'
                sh 'terraform workspace dev'
                sh 'terraform apply --auto-approve'
                sh 'terraform output -json > output.json'
                stash includes: 'output.json', name: 'tf_output'
            }
        }
      }
    }

    stage('ansible') {
      steps {
            withAWS(credentials: 'epuerta-challenge', region: 'us-east-2') {
              dir('infra/ansible') {
                  unstash '../infra/app/tf_output'
                  sh '''
                  #! /bin/bash
                  set -x 
                  set -e 
                  aws secretsmanager get-secret-value --secret-id epuerta/challenge --output json | jq '. | .SecretString' | python3 -c 'import json,sys;obj=json.loads(json.load(sys.stdin));print(obj.get("dev_private"))' > key_file
                  ansible-playbook -i inventories/aws/dev.aws_ec2.yml plays/challenge/site.yml --ssh-common-args='-o StrictHostKeyChecking="no" -o ProxyCommand="ssh -W %h:%p ubuntu@'$(jq '.bastion_ip.value' tf_output)'"'
                  ansible-playbook -i inventories/aws/dev.aws_ec2.yml plays/challenge/webservers.yml 
                '''
              }
            }
        }
    }
  }

}
