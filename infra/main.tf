module "vpc" {
  source = "./modules/vpc"

  name            = local.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "s3_bronze" {
  source      = "./modules/s3"
  bucket_name = local.bronze_bucket
}

module "s3_silver" {
  source      = "./modules/s3"
  bucket_name = local.silver_bucket
}

module "s3_gold" {
  source      = "./modules/s3"
  bucket_name = local.gold_bucket
}

module "iam" {
  source = "./modules/iam"

  role_name = local.iam_role_name
}

module "rds" {
  source = "./modules/rds"

  name            = local.rds_name
  db_name         = local.db_name
  username        = var.db_username
  password        = var.db_password
  private_subnets = module.vpc.private_subnets
}

module "databricks" {
  source = "./modules/databricks"
  count  = var.enable_databricks ? 1 : 0

  cluster_name = local.cluster_name
}