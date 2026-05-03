provider "aws" {
  region = var.region
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}