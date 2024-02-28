# provider
provider "aws" {
    region = "us-east-1"
  }

# generate randomised names
resource "random_id" "random_id_generator" {
    byte_length = 8

}


variable "topic_arn" {
  description = "topic arn for sns"
  type        = string
  default     = "arn:aws:sns:us-east-1:126751535369:Group4-email"

}


####--------------------------------------- S3 bucket --------------------------------------------####
resource "aws_s3_bucket" "scripts" {
    bucket = "deployingscripts-${random_id.random_id_generator.hex}"
    
    tags = {
        project_type = "demo"
    } 
}
resource "aws_s3_bucket_ownership_controls" "scripts" {
  bucket = aws_s3_bucket.scripts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "scripts" {
  bucket = aws_s3_bucket.scripts.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "scripts" {
  depends_on = [
    aws_s3_bucket_ownership_controls.scripts,
    aws_s3_bucket_public_access_block.scripts,
  ]

  bucket = aws_s3_bucket.scripts.id
  acl    = "public-read"
}
