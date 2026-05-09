locals {

  name_suffix = "${var.project}_${var.env}"

  #########################################
  # CORE INFRA
  #########################################

  vpc_name = "${var.project}-vpc-${var.env}"

  rds_name = "rl-db-${var.env}"

  iam_role_name = "role_${local.name_suffix}"

  cluster_name = "cluster_${local.name_suffix}"

  #########################################
  # SOURCE DATABASE
  #########################################

  db_name = var.db_name

  #########################################
  # TARGET DATABASES / SCHEMAS
  #########################################

  raw_db_name = "${var.db_name}_raw_${var.env}"

  replicated_db_name = "${var.db_name}_replicated_${var.env}"

  unified_db_name = "${var.db_name}_unified_${var.env}"
}