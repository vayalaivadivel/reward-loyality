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

variable "databricks_host" {}
variable "databricks_token" {}