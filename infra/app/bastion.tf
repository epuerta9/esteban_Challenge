
resource "aws_instance" "ansible_bastion" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro" #input
    key_name = aws_key_pair.esteban-challenge-key.key_name
    vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
    subnet_id = module.network.vpc_public_subnet_id[0]
    tags = {
      "Name" = "esteban_challenge_bastion"
      "vpc" = module.network.vpc_name
      "env" = var.env
      "role" = "bastion"
    }
}

## security group
resource "aws_security_group" "bastion_sg" {
  name = "${var.env}_bastion_sg"
  description = "allows 22 from master ansible host aka my local laptop"
  vpc_id = module.network.vpc_id
  ingress = [
      {
          description = "22 from local laptop"
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          security_groups = null
          self = null
          ipv6_cidr_blocks = null
          prefix_list_ids = null
          description = null
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