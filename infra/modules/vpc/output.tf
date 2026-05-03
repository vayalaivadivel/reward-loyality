output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "default_sg_id" {
  value = aws_security_group.default.id
}

output "db_name" {
  value = module.rds.db_name
}