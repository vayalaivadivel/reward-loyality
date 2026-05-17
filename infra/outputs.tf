output "vpc_id" {
  value = module.vpc.vpc_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "bastion_public_ip" {
  value = module.ec2.public_ip
}

output "bastion_public_dns" {
  value = module.ec2.public_dns
}

output "bastion_ssh_command" {
  value = "ssh -i bastion-key-new.pem ubuntu@${module.ec2.public_ip}"
}

output "db_name" {
  value = var.db_name
}

variable "ssh_user" {
  default = "ubuntu"
}

output "hop_alb_url" {

  value = module.hop.alb_dns
}

output "hop_ecr_url" {
  value = module.hop_ecr.repository_url
}


output "alb_dns" {

  value = module.hop.alb_dns
}