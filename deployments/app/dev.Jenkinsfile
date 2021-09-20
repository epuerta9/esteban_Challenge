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
                sh 'terraform output -json > ../ansible/tf_output.json'
                // stash includes: 'output.json', name: 'tf_output'
            }
        }
      }
    }

    stage('ansible') {
      steps {
            withAWS(credentials: 'epuerta-challenge', region: 'us-east-2') {
            //   dir('infra/app'){
            //     unstash 'tf_output'
            //     sh '''
            //     #!/bin/bash
            //     set -x 
            //     set -e
            //     export BASTION=$(jq '.bastion_ip.value' tf_output)
            //     echo $BASTION
            //     '''
            //   }
              dir('infra/ansible') {
                  sh '''
                  #! /bin/bash
                  set -x 
                  set -e 
                  export BASTION=$(jq -r '.bastion_ip.value' tf_output.json)
                  echo $BASTION
                  aws secretsmanager get-secret-value --secret-id epuerta/challenge --output json | jq '. | .SecretString' | python3 -c 'import json,sys;obj=json.loads(json.load(sys.stdin));print(obj.get("dev_private"))' > key_file
                  ansible-playbook -i inventories/aws/dev.aws_ec2.yml plays/challenge/site.yml --ssh-common-args='-o StrictHostKeyChecking="no" -o ProxyCommand="ssh -W %h:%p ubuntu@'$BASTION'"'
                  ansible-playbook -i inventories/aws/dev.aws_ec2.yml plays/challenge/webservers.yml 
                '''
              }
            }
        }
    }
  }

}
