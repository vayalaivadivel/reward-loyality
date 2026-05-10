variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet where EC2 will be deployed"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment (dev/stage/prod)"
  type        = string
}

# -------- DB VARIABLES --------

variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "instance_profile_name" {}
variable "private_key_path" {
  type = string
}


resource "null_resource" "wait_for_hop" {

  depends_on = [
    aws_instance.bastion
  ]

  connection {

    type = "ssh"

    host = aws_instance.bastion.public_ip

    user = "ubuntu"

    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {

    inline = [

      "echo 'Waiting for Apache Hop to start...'",

      "until sudo ss -tulnp | grep 8080; do sleep 15; done",

      "echo 'Apache Hop is running!'"
    ]
  }
}