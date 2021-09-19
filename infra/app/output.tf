output "key_name" {
  value = aws_key_pair.esteban-challenge-key.key_name
}

output "instance_ip" {
    value = aws_instance.webapp.public_ip
}

output "bastion_ip" {
    value = aws_instance.ansible_bastion.public_ip
}