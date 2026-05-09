#########################################
# RDS SUBNET GROUP
#########################################

resource "aws_db_subnet_group" "this" {

  name = "${var.name}-subnet"

  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.name}-subnet"
  }
}

#########################################
# RDS SECURITY GROUP
#########################################

resource "aws_security_group" "rds" {

  name = "${var.name}-rds-sg"

  vpc_id = var.vpc_id

  #################################
  # EGRESS
  #################################

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

#########################################
# MYSQL CDC PARAMETER GROUP
#########################################

resource "aws_db_parameter_group" "mysql_cdc_pg" {

  name = "${var.name}-mysql-cdc-pg"

  family = "mysql8.0"

  description = "Parameter group for MySQL CDC using AWS DMS"

  #################################
  # REQUIRED FOR CDC
  #################################

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_row_image"
    value = "FULL"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  #################################
  # OPTIONAL BUT RECOMMENDED
  #################################

  parameter {
    name  = "binlog_retention_hours"
    value = "24"
  }

  tags = {
    Name = "${var.name}-mysql-cdc-pg"
  }
}

#########################################
# MYSQL RDS
#########################################

resource "aws_db_instance" "mysql" {

  identifier = var.name

  db_name = var.db_name

  #################################
  # ENGINE
  #################################

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  #################################
  # CREDENTIALS
  #################################

  username = var.username

  password = var.password

  #################################
  # NETWORK
  #################################

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  #################################
  # CDC PARAMETER GROUP
  #################################

  parameter_group_name = aws_db_parameter_group.mysql_cdc_pg.name

  #################################
  # BACKUP
  #################################

  backup_retention_period = 7

  delete_automated_backups = false

  #################################
  # LOGS
  #################################

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  #################################
  # IMPORTANT
  #################################

  apply_immediately = true

  skip_final_snapshot = true

  #################################
  # TIMEOUTS
  #################################

  timeouts {
    create = "30m"
    delete = "30m"
  }

  tags = {
    Name = var.name
  }
}