env     = "dev"
project = "rl"

region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24",  "10.0.20.0/24"]

db_username = "admin"
db_password = "StrongPassword123!"
db_name = "rldb"
key_name = "bastion-key"
# databricks_host  = "https://adb-xxxx"
# databricks_token = "xxxx"