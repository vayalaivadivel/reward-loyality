module "vpc" {
  source = "./modules/vpc"

  name            = local.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "s3" {
  source = "./modules/s3"

  bucket_name = local.s3_name
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

  cluster_name = local.cluster_name
}