output "db_name" {
  value = var.db_name
}
output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}