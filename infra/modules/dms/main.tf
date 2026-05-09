resource "aws_dms_replication_instance" "dms_instance" {

  replication_instance_id = "mysql-dms-instance"

  replication_instance_class = "dms.t3.medium"

  allocated_storage = 100

  publicly_accessible = false
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

resource "aws_dms_endpoint" "s3_target" {

  endpoint_id = "${var.env}-raw-s3-target"

  endpoint_type = "target"

  engine_name = "s3"

  service_access_role = var.dms_role_arn

  extra_connection_attributes = join(
    ";",
    [
      "bucketName=${var.raw_bucket}",
      "bucketFolder=mysql-cdc/",
      "compressionType=GZIP"
    ]
  )
}

resource "aws_dms_replication_task" "mysql_cdc_task" {

  replication_task_id = "mysql-cdc-task"

  migration_type = "full-load-and-cdc"

  replication_instance_arn = aws_dms_replication_instance.dms_instance.replication_instance_arn

  source_endpoint_arn = aws_dms_endpoint.mysql_source.endpoint_arn

  target_endpoint_arn = aws_dms_endpoint.s3_target.endpoint_arn

  table_mappings = jsonencode({
    rules = [{
      "rule-type" = "selection",
      "rule-id"   = "1",
      "rule-name" = "1",

      "object-locator" = {
        "schema-name" = "%",
        "table-name"  = "%"
      },

      "rule-action" = "include"
    }]
  })
}   