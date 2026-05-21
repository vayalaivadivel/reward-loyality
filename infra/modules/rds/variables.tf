variable "name" {}
variable "db_name" {}
variable "username" {}
variable "password" {}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
variable "dms_security_group_id" {

  type = string
}