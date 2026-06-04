# S3バケット
resource "aws_s3_bucket" "bronze" {
  bucket = "${var.project_name}-bronze"
  tags   = { Environment = "dev" }
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

# 外部ロケーションの設定
resource "aws_iam_role" "databricks_unity_catalog" {
  name = "databricks_unity_catalog_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = [
          "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL",
          "arn:aws:iam::742402427301:role/databricks_unity_catalog_role"
        ]
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = "07cfac68-8321-4296-a180-9cc6ab3dbbef"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "databricks_unity_catalog" {
  name = "databricks-unity-catalog-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ]
      Resource = [
        aws_s3_bucket.bronze.arn,
        "${aws_s3_bucket.bronze.arn}/*",
        aws_s3_bucket.silver.arn,
        "${aws_s3_bucket.silver.arn}/*",
        aws_s3_bucket.gold.arn,
        "${aws_s3_bucket.gold.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "databricks_unity_catalog" {
  role       = aws_iam_role.databricks_unity_catalog.name
  policy_arn = aws_iam_policy.databricks_unity_catalog.arn
}

