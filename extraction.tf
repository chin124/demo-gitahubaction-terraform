# provider
provider "aws" {
    region = "us-east-1"
    #access_key = "ASIAR3AX26EEQVCGCAWH"
    #secret_key = "AE36ejH92yw5RoSVc0RAHZ7UHfl8aZC0Zp5ygj9B"
    #token = "FwoGZXIvYXdzEN7//////////wEaDGjsSuMpLhzJEMb1xSLJAfAgStYjYT49VzbNeRgmqszOFG3dObEh3okj4AED9v7YPo9xk1JulLSNIc/OsNc73kmEiWrs9DIyKI25CRhVbjt3a0kddGev7UXAJNsX4MlydUD/9QxhmZSytZESzrtn+k8gX3TuCfUdeJNTW0nLqOQOkKyQD3VjkqEO0jNbL3c8A/im5YYPjcvjj00pztk9v3IOYIpqKwBGYyoM0eTwBgKW8kmwVoVSZ7Nft/vuUdBfkf6pZcyCkPAApe2TjTLO8QGQURo1562LDSiPovCuBjIt3omTt/p8SkTbIoXUU8o+3R8CMWjg9vYKa4AML0HRqhP2Q6oRv7JNBxXzsWMx"
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
