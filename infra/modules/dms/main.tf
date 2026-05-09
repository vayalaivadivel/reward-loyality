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

  s3_settings {

    bucket_name = var.raw_bucket

    bucket_folder = "mysql-cdc/"

    compression_type = "GZIP"

    service_access_role_arn = var.dms_role_arn

    cdc_inserts_only = false

    timestamp_column_name = "dms_timestamp"
  }
}
resource "aws_dms_replication_task" "mysql_cdc_task" {

  replication_task_id = "${var.env}-mysql-cdc-task"

  migration_type = "full-load-and-cdc"

  replication_instance_arn = aws_dms_replication_instance.dms_instance.replication_instance_arn

  source_endpoint_arn = aws_dms_endpoint.mysql_source.endpoint_arn

  target_endpoint_arn = aws_dms_endpoint.s3_target.endpoint_arn

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

    TargetMetadata = {

      TargetSchema = ""

      SupportLobs = true

      FullLobMode = false

      LobChunkSize = 64

      LimitedSizeLobMode = true

      LobMaxSize = 32

      ParallelLoadThreads = 0
    }

    FullLoadSettings = {

      TargetTablePrepMode = "DO_NOTHING"

      CreatePkAfterFullLoad = false

      StopTaskCachedChangesApplied = false

      StopTaskCachedChangesNotApplied = false

      MaxFullLoadSubTasks = 8
    }

    Logging = {

      EnableLogging = true
    }

    ControlTablesSettings = {

      ControlSchema = ""

      HistoryTimeslotInMinutes = 5

      HistoryTableEnabled = false

      SuspendedTablesTableEnabled = false

      StatusTableEnabled = false

      FullLoadExceptionTableEnabled = false
    }

    StreamBufferSettings = {

      StreamBufferCount = 3

      StreamBufferSizeInMB = 8
    }

    ChangeProcessingDdlHandlingPolicy = {

      HandleSourceTableDropped = true

      HandleSourceTableTruncated = true

      HandleSourceTableAltered = true
    }

    ErrorBehavior = {

      DataErrorPolicy = "LOG_ERROR"

      DataTruncationErrorPolicy = "LOG_ERROR"

      TableErrorPolicy = "SUSPEND_TABLE"

      DataErrorEscalationPolicy = "SUSPEND_TABLE"
    }
  })

  depends_on = [
    aws_dms_endpoint.mysql_source,
    aws_dms_endpoint.s3_target,
    aws_dms_replication_instance.dms_instance
  ]
}