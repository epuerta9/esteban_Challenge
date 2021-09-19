variable "vpc_cidr" {
    type = string
}

variable "vpc_name" {
    type = string
}

variable "vpc_private_subnets" {
    type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_enable_nat_gateway" {
  type = bool
}
