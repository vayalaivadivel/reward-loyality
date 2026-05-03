output "vpc_id" {
  value = module.vpc.vpc_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_public_dns" {
  value = module.bastion.public_dns
}

output "bastion_ssh_command" {
  value = "ssh -i bastion-key.pem ec2-user@${module.bastion.public_ip}"
}

output "db_name" {
  value = var.db_name
}