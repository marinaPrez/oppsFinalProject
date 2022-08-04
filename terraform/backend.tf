/* resource "aws_s3_bucket" "s3-bucket-ops-001" {
  bucket = "s3-bucket-ops-001"
} */

/* resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_dynamodb_ops-01"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
} */



terraform {
  backend "s3" {
    bucket = "s3-bucket-ops-001"
    key    = "terraform.tfstate"
    dynamodb_table = "terraform_dynamodb_ops-01"
    region = "us-east-2"
  }
}

