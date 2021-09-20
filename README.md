# esteban_Challenge
create and deploy a secure and scalable web application

# Overview

This project is broken down into following 4 major sections, dockerizing the django webapp, building out the infrastructure with Terraform, configuring the newly created hosts with ansible, and finally deploying that with Jenkins.

1 webapp gets deployed behind an ALB and is only accessible by vpc specific bastion hosts that ansible-master (in this case my laptop) proxy's through in order to configure it.


# Webapp

In the root of this project there is a django application named webapp that supports a simple html page and can be started with the steps below

## setup the venv

```python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt ```
## start the webserver

```python webapp/manage.py runserver```

This app is the center of the deployment and the goal is to be able to dockerize it making it more mobile with stable, repeatable results


```
FROM python:3.8
RUN mkdir /app/
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY ./webapp /app/
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"] 
```

## Building and publishing 
a Jenkinsfile in the build/ directory handles the multibranch logic to run the build process that will tag the container with the branch and a version, log into ecr based on jenkins aws permissions and push to a public repo. This will later be used by ansible to pull from during the configuration step.

Jenkins server was also specifically built for this project and the docker file can be found at tools/jenkins/Dockerfile. 

additional tools installed after boot with the ```sudo docker exec -it -u 0 jenkins bash``` include 

* awscli 
* terraform 
* ansible
* boto3


# Terraform 

On to the building part...

The approach taken for this was to use an aws provided module for vpc's and write a wrapper module around it for under infra/networking that can extend the functionality of the vpc build while only allowing its calling module a small window of inputs outputs for resuability. This design choice was based on the thought of future development around the vpc infrastructure without affecting app deployments.

The app specific building logic is in the infra/app directory and is broken down by role. 

* main.tf includes all the app building logic and specific to the webapp. This includes things like alb, sg groups, instance.
* bastion.tf includes the logic for creating the bastion host and is the only way to reach the webapp host creating a secure environment without exposing ports on the webapp
* variables.tf is where the entry point of this terraform module is and seperates different terraform workspace configuration.
* terraform.tfvars is the default defined variables that map to dev environments 
* stage and prod.tfvars both have to be explicitely passed in via the cli but that is logic that is handled by jenkinsfile
* output.tf has the needed output of the bastion public ip so it can later be used in the proxy command

## Terraform security and secrets

secrets are handled via aws secrets manager and dynamically brought down at runtime. This will allow for easier rotation of keys in the future and ensure that the system won't break with these changes.


# Ansible

After infrastructure is built, ansible, located in infra/ansible, configures the hosts based on ec2-dynamic inventory. Terraform tags the instances so that they can be distinguished by role later. Role based seperation make up the inventory and how playbooks target hosts. 

* role_bastion
* role_web

the two roles defined and with specific group_vars in infra/ansible/inventories/group_vars ( where the ssh proxy command is defined)

ansible playbooks are divided by a infra/ansible/plays/challenge/site.yml and a infra/ansible/plays/challenge/webserver.yml which call in appropriate roles. 

## site.yml
site.yml sets up the commmon tools and packages needed across the environments. upgrade, docker, py-docker just to name a few. It also bootstraps the nodes with a node_exporter for a future grafana/prometheus install. (I used this in a previous home project and would have liked to be able to set up monitoring around this stack as well)

## webserver.yml
a very trivial playbook that only pulls down the image that was publish to ecr. ** thing to note ** ecr has a sessioned expired so ansible-master needs to re-login to ecr for this playbook to work


## Ansible afterthoughts
ansible was the toughest part about this build as I had a hard time for jenkins to ssh proxy correctly to the hosts. I abandoned the jenkins ansible and run the ansible commmands directly on my laptop. 

overall a lot of troubleshooting went into ansible section

# Jenkins
 
 Jenkins is also setup as a local docker container that handles the multibranch deployments. The point of this was to show, in a team setting you would control how branch commits, tags, and commits will affect the build process.

 the jenkinsfiles can be found in deployments/app/ and specify the three basic environments where terraform can build out a new vpc. 

 AWS credentials are handled with jenkins credentials are are referred back using withAWS in a build step to avoid leaking sensitive information.
 
 all jenkins jobs are built through source controlled jenkinsfiles as this follows the IaC mentally when making infrastructure immutable including jenkin hosts




