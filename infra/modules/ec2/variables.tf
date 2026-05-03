variable "ami" {}
variable "public_subnet_id" {}
variable "sg_id" {}
variable "key_name" {}
variable "name" {}
variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}