variable "region" {}

variable "project" {
  default = "rl"
}

variable "env" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "db_username" {}
variable "db_password" {}
variable "db_name" {}

variable "databricks_host" {
  type    = string
  default = ""
}

variable "databricks_token" {
  type    = string
  default = ""
}
variable "enable_databricks" {
  type    = bool
  default = false
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "hop_url" {}
variable "hop_username" {}
variable "hop_password" {}

variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {}

variable "aws_region" {

  type = string
}