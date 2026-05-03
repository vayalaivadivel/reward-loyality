resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "mysql" {
  identifier = var.name
  db_name    = var.db_name

  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = var.username
  password = var.password

  skip_final_snapshot = true
}