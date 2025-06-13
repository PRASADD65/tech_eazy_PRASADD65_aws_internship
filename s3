# s3.tf

# -----------------------------------------------------------------------------
# S3 Bucket for Logs
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "app_logs_bucket" {
  bucket = var.s3_bucket_name # Uses the bucket name defined in variable.tf
  # Removed: acl    = "private"
  
  tags = {
    Name = "${var.stage}-app-logs"
  }
}

# Explicitly define S3 Bucket ACL
resource "aws_s3_bucket_acl" "app_logs_bucket_acl" {
  bucket = aws_s3_bucket.app_logs_bucket.id
  acl    = "private"
}

# -----------------------------------------------------------------------------
# S3 Bucket Public Access Block
# Recommended for all S3 buckets to prevent unintended public access.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "app_logs_bucket_access_block" {
  bucket = aws_s3_bucket.app_logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# S3 Bucket Lifecycle Rule: Delete logs after 7 days
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "app_logs_lifecycle_rule" {
  bucket = aws_s3_bucket.app_logs_bucket.id

  rule {
    id     = "delete_old_app_logs"
    status = "Enabled"

    filter {
      prefix = "app/logs/" # Apply rule only to objects within the 'app/logs/' prefix
    }

    expiration {
      days = 7 # Delete objects after 7 days
    }
  }
}
