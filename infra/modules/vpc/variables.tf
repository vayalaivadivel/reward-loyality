variable "name" {}
variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "project" {
  type = string
}

variable "env" {
  type = string
}