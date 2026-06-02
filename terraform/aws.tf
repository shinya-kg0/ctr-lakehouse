# S3バケット
resource "aws_s3_bucket" "bronze" {
  bucket = "${var.project_name}-bronze"
  tags = { Environment = "dev" }
}

resource "aws_s3_bucket" "silver" {
  bucket = "${var.project_name}-silver"
}

resource "aws_s3_bucket" "gold" {
  bucket = "${var.project_name}-gold"
}

# パブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "bronze" {
  bucket                  = aws_s3_bucket.bronze.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "silver" {
  bucket                  = aws_s3_bucket.silver.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "gold" {
  bucket                  = aws_s3_bucket.gold.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

