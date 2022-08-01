resource "aws_s3_bucket" "s3-bucket-opsschool" {
  bucket = "s3-bucket-opsschool"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_dynamodb_oppschool"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

/* 
terraform {
  backend "s3" {
    bucket = "s3-bucket-opsschool"
    key    = "terraform.tfstate"
    dynamodb_table = "terraform_dynamodb_oppschool"
    region = "us-west-2"
  }
} */

