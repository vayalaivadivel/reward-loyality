resource "aws_dms_replication_instance" "dms_instance" {

  replication_instance_id = "mysql-dms-instance"

  replication_instance_class = "dms.t3.small"

  allocated_storage = 20

  publicly_accessible = false

  depends_on = [
    var.dms_vpc_role_dependency
  ]
}

resource "aws_dms_endpoint" "mysql_source" {

  endpoint_id = "mysql-source"

  endpoint_type = "source"

  engine_name = "mysql"

  server_name = var.mysql_host

  port = 3306

  username = var.mysql_user

  password = var.mysql_password

  database_name = var.mysql_database
}

resource "aws_dms_endpoint" "mysql_target" {

  endpoint_id = "${var.env}-mysql-target"

  endpoint_type = "target"

  engine_name = "mysql"

  server_name = var.mysql_host

  port     = 3306
  username = var.mysql_user

  password = var.mysql_password

  database_name = var.raw_db_name

  ssl_mode = "none"
}

resource "aws_dms_replication_task" "mysql_cdc_task" {

  replication_task_id = "${var.env}-mysql-full-load-task"

  migration_type = "full-load"

  replication_instance_arn = aws_dms_replication_instance.dms_instance.replication_instance_arn

  source_endpoint_arn = aws_dms_endpoint.mysql_source.endpoint_arn

  target_endpoint_arn = aws_dms_endpoint.mysql_target.endpoint_arn

  #########################################
  # TABLE MAPPINGS
  #########################################

  table_mappings = jsonencode({

    rules = [

      {
        "rule-type" = "selection"

        "rule-id" = "1"

        "rule-name" = "1"

        "object-locator" = {

          "schema-name" = "%"

          "table-name" = "%"
        }

        "rule-action" = "include"
      }
    ]
  })

  #########################################
  # TASK SETTINGS
  #########################################

  replication_task_settings = jsonencode({

    FullLoadSettings = {

      TargetTablePrepMode = "DO_NOTHING"
    }

    Logging = {

      EnableLogging = true
    }
  })

  depends_on = [
    aws_dms_endpoint.mysql_source,
    aws_dms_endpoint.mysql_target,
    aws_dms_replication_instance.dms_instance
  ]
}