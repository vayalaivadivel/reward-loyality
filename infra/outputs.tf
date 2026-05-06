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
  value = "ssh -i bastion-key-new.pem ubuntu@${module.bastion.public_ip}"
}

output "db_name" {
  value = var.db_name
}

variable "ssh_user" {
  default = "ubuntu"
}

output "raw_bucket" {
  value = module.s3_raw.bucket_name
}

output "replicated_bucket" {
  value = module.s3_replicated.bucket_name
}

output "unified_bucket" {
  value = module.s3_unified.bucket_name
}