resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = "t3.micro"

  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name

  tags = {
    Name = var.name
  }
}