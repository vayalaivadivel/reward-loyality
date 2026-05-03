terraform {
  backend "s3" {
    bucket         = "vadivel-terraform-bucket"
    key            = "reward_loyality/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}