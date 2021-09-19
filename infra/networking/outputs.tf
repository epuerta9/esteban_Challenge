

output "vpc_name" {
    value = var.vpc_name
}

output "vpc_private_subnet_id" {
  value = module.vpc.private_subnets
}

output "vpc_public_subnet_id" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}