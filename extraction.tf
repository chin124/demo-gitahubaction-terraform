# provider
provider "aws" {
    region = "us-east-1"
    access_key = "ASIAR3AX26EESGZSLFOQ"
    secret_key = "c01ajLpje/yr3m41EjZYn4if5UjJ1/r4rBmeF+GJ"
    token = "FwoGZXIvYXdzEPn//////////wEaDNL8VwwUm/My9/p6PyLJAYIBtJjXz5RjAToz+qf4RWBJx3WZwt+XaLmkPwMhd7I7hvi75Vtb63JEw5PEnXWFVJ4gy8009hH1vy/yBM9avw9Jei0lFRhDjyEELS31CxMZvbQYIFuteWtzswc6JxoDWNovWP3zy0Z1gE15roGiIqS4ZENFxJVKGTzI7F5A5TJzGcEwkIQJSvQR0dwd5lW1ObUvX9TFKCx13M/GGtp16F2bRhwN857ePyE65FKa/wmZIOT1f7wdU7YTmD4uIyo9Q5Q/OqMWNIHECSjHn/auBjItHManULx5FW9jyjyw8EaI8cqeT/frlj5pvmc+isViUoCmOxVdb9K5Z3gCMtDd"

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
