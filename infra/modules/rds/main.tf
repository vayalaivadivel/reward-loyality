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
  
  timeouts {
    create = "30m"
    delete = "30m"
  }
  vpc_security_group_ids = [aws_security_group.rds.id]
}

resource "aws_security_group" "rds" {
  name   = "${var.name}-rds-sg"
  vpc_id = var.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}