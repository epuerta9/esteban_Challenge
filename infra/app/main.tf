module "network" {
    source = "../networking"
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr 
    vpc_private_subnets = var.vpc_private_subnets
    vpc_public_subnets = var.vpc_public_subnets
    vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
}

## pub_key
data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:us-east-2:341831142426:secret:epuerta/challenge-RRZNGj"
}

data "aws_secretsmanager_secret_version" "content" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id

}

locals {
  secret_key = jsondecode(data.aws_secretsmanager_secret_version.content.secret_string)["${var.env}_public"]
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}


##  web instance

resource "aws_instance" "webapp" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.web_app_instance_size #input
    key_name = aws_key_pair.esteban-challenge-key.key_name
    vpc_security_group_ids = ["${aws_security_group.web_app_sg.id}"]
    subnet_id = module.network.vpc_public_subnet_id[0]
    tags = {
      "Name" = "esteban_challenge_web"
      "vpc" = module.network.vpc_name
      "env" = var.env
      "role" = "web"
    }
    depends_on = [
        aws_security_group.web_app_sg
    ]
}

## security group
#["0.0.0.0/0"] egg ["${aws_security_group.bastion_sg.id}"] in ["${aws_security_group.elb_app_sg.id}"]
resource "aws_security_group" "web_app_sg" {
  name = "${var.env}_web_sg"
  description = "allows 80 from loadbalancer and 22 from ansible bastion"
  vpc_id = module.network.vpc_id
  ingress = [
      {
          description = "HTTP from load"
          from_port = 80
          to_port = 8000
          protocol = "tcp"
          cidr_blocks =  null
          security_groups = ["${aws_security_group.elb_app_sg.id}"]
          self = null
          ipv6_cidr_blocks = null
          prefix_list_ids = null
      },
      {
          description = "22 from bastion"
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = null
          security_groups = ["${aws_security_group.bastion_sg.id}"]
          self = null
          ipv6_cidr_blocks = null
          prefix_list_ids = null
      }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups = null
      self = null
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      description = null
    }
  ]

  tags = {
    "env" = "${var.env}"
  }
}

## load balancer security group 
## security group
resource "aws_security_group" "elb_app_sg" {
  name = "${var.env}_app_sg"
  description = "allows 443 from anywhere"
  vpc_id = module.network.vpc_id
  ingress = [
      {
          description = "external load balancer rules"
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          security_groups = null
          self = null
          ipv6_cidr_blocks = null
          prefix_list_ids = null
      }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      security_groups = null
      self = null
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      description = null
    }
  ]
  tags = {
    "env" = "${var.env}"
  }
}
## load balancer
resource "aws_elb" "web_app_elb" {
  name = "${var.env}-web-elb"
  subnets = ["${module.network.vpc_public_subnet_id[0]}"]
  security_groups = [ "${aws_security_group.elb_app_sg.id}" ]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = var.ssl_cert_id

  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2 
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  instances = [aws_instance.webapp.id]
}
## key pair used
resource "aws_key_pair" "esteban-challenge-key" {
    key_name = var.challenge_env_key
    public_key = local.secret_key    
}

