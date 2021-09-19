    vpc_name = "dev-challenge-vpc" 
    vpc_cidr = "10.3.0.0/16" 
    vpc_private_subnets = ["10.3.1.0/24"] 
    vpc_public_subnets = ["10.3.2.0/24"]
    vpc_enable_nat_gateway = false
    web_app_instance_size = "t3.micro"
    challenge_env_key = "dev-challenge-key"
    env = "prod"
    ssl_cert_id = "arn:aws:acm:us-east-2:341831142426:certificate/11aea1f1-7247-4117-8eb6-0719abcd14de"