module "vpc" {
  source = "./modules/vpc"

  name = local.vpc_name

  project = var.project # 👈 ADD
  env     = var.env     # 👈 ADD

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

module "bastion" {
  source = "./modules/ec2"

  name = "bastion-${var.project}-${var.env}"

  ami              = "ami-0f5ee92e2d63afc18"
  public_subnet_id = module.vpc.public_subnets[0]
  sg_id            = module.vpc.default_sg_id
  key_name         = "bastion-key"

  vpc_id = module.vpc.vpc_id
  rds_endpoint = module.rds.rds_endpoint
  db_username  = var.db_username
  db_password  = var.db_password
  db_name      = var.db_name
}