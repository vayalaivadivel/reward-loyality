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