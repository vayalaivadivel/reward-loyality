variable "name" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "private_subnets" { type = list(string) }
variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}