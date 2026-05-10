module "vpc" {
  source = "./modules/vpc"

  name = local.vpc_name

  project = var.project
  env     = var.env

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# ✅ RDS FIRST
module "rds" {
  source = "./modules/rds"

  name            = local.rds_name
  db_name         = local.db_name
  username        = var.db_username
  password        = var.db_password
  private_subnets = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
}

# ✅ BASTION AFTER RDS
module "ec2" {

  source = "./modules/ec2"

  name = "bastion-${var.project}-${var.env}"

  ami = "ami-0f5ee92e2d63afc18"

  public_subnet_id = module.vpc.public_subnets[0]

  project = var.project

  env = var.env

  vpc_id = module.vpc.vpc_id

  key_name = var.key_name

  #################################
  # ADD THIS
  #################################

  instance_profile_name = module.iam.instance_profile_name

  #################################
  # RDS
  #################################

  rds_endpoint = module.rds.rds_endpoint

  db_username = var.db_username

  db_password = var.db_password

  db_name = local.db_name
}

# ✅ SG RULE AFTER BOTH MODULES
resource "aws_security_group_rule" "bastion_to_rds" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  security_group_id        = module.rds.rds_sg_id
  source_security_group_id = module.ec2.sg_id
}

module "databricks" {
  source = "./modules/databricks"
  count  = var.enable_databricks ? 1 : 0

  cluster_name = local.cluster_name
}


module "lambda" {
  source          = "./modules/lambda"
  env             = var.env
  lambda_role_arn = module.iam.lambda_role_arn
  hop_url         = "http://${module.ec2.public_ip}:8080/hop/runWorkflow"
  hop_username    = var.hop_username
  hop_password    = var.hop_password
}

module "eventbridge" {
  source      = "./modules/eventbridge"
  lambda_arn  = module.lambda.lambda_arn
  lambda_name = module.lambda.lambda_name
}

module "dms" {
  source                  = "./modules/dms"
  env                     = var.env
  mysql_host              = module.rds.rds_endpoint
  mysql_user              = var.db_username
  mysql_password          = var.db_password
  mysql_database          = local.db_name
  raw_db_name             = local.raw_db_name
  dms_role_arn            = module.iam.dms_role_arn
  dms_vpc_role_dependency = module.iam.dms_vpc_role_ready
  security_group_id       = module.ec2.sg_id
  private_subnets         = module.vpc.private_subnets
}

module "iam" {
  source    = "./modules/iam"
  project   = var.project
  env       = var.env
  role_name = "${var.project}-${var.env}-role"
}