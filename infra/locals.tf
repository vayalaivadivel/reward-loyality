locals {
  name_suffix = "${var.project}_${var.env}"

  vpc_name      = "vpc_${local.name_suffix}"
  s3_name       = "s3_${local.name_suffix}"
  rds_name      = "rl-db-${var.env}"        # EXACT requirement
  db_name       = "rldb${var.env}"          # MySQL-friendly (no hyphen)
  iam_role_name = "role_${local.name_suffix}"
  cluster_name  = "cluster_${local.name_suffix}"

  # 🪣 Data lake buckets (Bronze / Silver / Gold) 
  bronze_bucket = "${var.project}-bronze-${var.env}"
  silver_bucket = "${var.project}-silver-${var.env}"
  gold_bucket = "${var.project}-gold-${var.env}"
}