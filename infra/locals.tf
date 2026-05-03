locals {
  name_suffix = "${var.project}_${var.env}"

  vpc_name      = "vpc_${local.name_suffix}"
  s3_name       = "s3_${local.name_suffix}"
  rds_name      = "mysql_${local.name_suffix}"
  db_name       = "db_${local.name_suffix}"
  iam_role_name = "role_${local.name_suffix}"
  cluster_name  = "cluster_${local.name_suffix}"
}