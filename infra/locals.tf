locals {
  name_suffix = "${var.project}_${var.env}"

  vpc_name      = "${var.project}-vpc-${var.env}"
  s3_name       = "s3_${local.name_suffix}"
  rds_name      = "rl-db-${var.env}" # EXACT requirement
  db_name       = var.db_name
  iam_role_name = "role_${local.name_suffix}"
  cluster_name  = "cluster_${local.name_suffix}"

  # 🪣 Data lake buckets (Bronze / Silver / Gold) 
  raw_bucket        = "${var.project}-raw-${var.env}-${random_string.suffix.result}"
  replicated_bucket = "${var.project}-replicated-${var.env}-${random_string.suffix.result}"
  unified_bucket    = "${var.project}-unified-${var.env}-${random_string.suffix.result}"


}