# iam.tf

# -----------------------------------------------------------------------------
# IAM Role 1.b: Role for EC2 to Create Buckets and Upload Objects
# This role will be attached to the EC2 instance.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "app_instance_role" {
  name_prefix        = "${var.stage}-ec2-s3-upload-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.stage}-ec2-s3-upload-role"
  }
}

# IAM Policy for Role 1.b: Permissions to Create Buckets and Upload Objects
# IMPORTANT: This policy explicitly denies s3:GetObject and s3:ListBucket for the specified bucket path.
resource "aws_iam_policy" "s3_upload_policy" {
  name_prefix = "${var.stage}-s3-upload-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl" # Needed if public access is modified or specific ACLs are set
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect   = "Deny", # Explicitly deny read/list access
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Attach the policy to Role 1.b
resource "aws_iam_role_policy_attachment" "app_instance_role_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

# IAM Instance Profile for Role 1.b
# This is what gets attached to the EC2 instance.
resource "aws_iam_instance_profile" "app_instance_profile" {
  name_prefix = "${var.stage}-ec2-s3-upload-profile"
  role        = aws_iam_role.app_instance_role.name

  tags = {
    Name = "${var.stage}-ec2-s3-upload-profile"
  }
}

# -----------------------------------------------------------------------------
# IAM Role 1.a: Role for Read-Only Access to S3
# This role is for verification, not attached to the EC2 instance.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "s3_read_only_role" {
  name_prefix        = "${var.stage}-s3-read-only-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" # Allows your AWS account root to assume (for CLI testing)
        }
      }
    ]
  })

  tags = {
    Name = "${var.stage}-s3-read-only-role"
  }
}

# IAM Policy for Role 1.a: Read-Only S3 Access
resource "aws_iam_policy" "s3_read_only_policy" {
  name_prefix = "${var.stage}-s3-read-only-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Attach the policy to Role 1.a
resource "aws_iam_role_policy_attachment" "s3_read_only_role_attachment" {
  role       = aws_iam_role.s3_read_only_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# Data source to get current AWS account ID for IAM policy
data "aws_caller_identity" "current" {}
