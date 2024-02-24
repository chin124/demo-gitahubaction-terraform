# provider
provider "aws" {
    region = "us-east-1"
    access_key = "ASIAR3AX26EE6VJXLIKG"
    secret_key = "XULlfWVDeOUgpETlcNt4KQb6VML+Jr6wa1UGOMxh"
    token = "FwoGZXIvYXdzEK3//////////wEaDP9MnNmuPGmCFMdCrCLJASY3N0fXwPsjr0LLHer3o2K9m2itv4sHXMZHAOxX98F38QvB6nj02FUVn1sZ4XM7kzs5TVTd5RpdfSNnTv2KIuIDzwXH9//vqWemcLNx4ezem00kZP9b9uSoMqgSQDwlXI0EcQ+bFuGyRLwl6gWszfi7K4hPUSw0tTegFxdUUX4PhMKLYOqriBREIZgQI7q5RK8k4sZTHqSElm5wMRkQtL+edvd4/6SZMGkl0D2SK6rRtWMkrvJ7KJnZa0JiSWK0vioxzug3Qa08RSiW1OWuBjIt/dpktWDEkya6J7PBv+NP2jmG1CifI5cUZzxqm/jMHYGguJL09VytUX477tPo"
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
