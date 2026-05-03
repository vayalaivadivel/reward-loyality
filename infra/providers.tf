terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}