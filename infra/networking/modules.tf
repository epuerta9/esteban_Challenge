##vpc module from aws  to contain at least 1 public subnet and can be used to house multiple webapps

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = var.vpc_name #input variable
    cidr = var.vpc_cidr #input variable
    azs = ["us-east-2a", "us-east-2b"]
    private_subnets = var.vpc_private_subnets #input
    public_subnets = var.vpc_public_subnets #input
    enable_nat_gateway = var.vpc_enable_nat_gateway #input

    tags = {
        env = "esteban-challenge"
    }
}