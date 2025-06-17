# -----------------------------------------------------------------------------
# IAM Role 1: Role for EC2 Instance to Upload Logs to S3 and Assume Read-Only Role
# This role is attached directly to the EC2 instance.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "app_instance_role" {
  name_prefix = "${var.stage}-app-instance-role"
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
    Name = "${var.stage}-app-instance-role" # Updated tag
  }
}

# IAM Policy for Role 1: S3 Upload and Assume Role Permissions
resource "aws_iam_policy" "ec2_s3_upload_policy" {
  name_prefix = "${var.stage}-ec2-s3-upload-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { # Allow EC2 to put objects into the specified S3 log prefix
        Effect = "Allow",
        Action = [
          "s3:CreateBucket", # Keep if needed
          "s3:PutObject",
          "s3:PutObjectAcl" # Often needed for aws s3 cp
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}", # Keep if needed for CreateBucket or general bucket access
          "arn:aws:s3:::${var.s3_bucket_name}/app/logs/*" # THIS IS CRUCIAL FOR LOGS
        ]
      },
      { # Allow EC2 to list objects within the specified S3 log prefix
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${var.s3_bucket_name}",
        Condition = {
          StringLike = {
            "s3:prefix" : "app/logs/*"
          }
        }
      },
      { # Allow EC2 to assume the S3 Read-Only Role
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.s3_read_only_role.arn # Allows assuming the read-only role
      },
      { # Explicitly deny read/list access for app logs (if you want this strictness)
        # Note: This DENY applies to the *entire* bucket.
        # If you need to read other objects outside app/logs/, adjust this.
        Effect = "Deny",
        Action = [
          "s3:GetObject" # Removed "s3:ListBucket" from here to allow it for 'app/logs/*'
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Attach Policy to EC2 S3 Upload Role
resource "aws_iam_role_policy_attachment" "ec2_s3_upload_policy_attach" {
  role       = aws_iam_role.app_instance_role.name # UPDATED: now references the renamed role
  policy_arn = aws_iam_policy.ec2_s3_upload_policy.arn
}

# IAM Instance Profile: Connects the EC2 instance to the role
# RENAMED from "app_profile" to "app_instance_profile" as per ec2.tf expectation
resource "aws_iam_instance_profile" "app_instance_profile" { # RENAMED
  name = "${var.stage}-app-instance-profile" # Updated name
  role = aws_iam_role.app_instance_role.name # UPDATED: now references the renamed role
}


# -----------------------------------------------------------------------------
# IAM Role 1.a: Role for Read-Only Access to S3
# This role is for verification, not attached to the EC2 instance directly.
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
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", # Allows your AWS account root to assume (for CLI testing)
            aws_iam_role.app_instance_role.arn # UPDATED: now references the renamed EC2 instance role
          ]
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

# Attach Policy to S3 Read-Only Role
resource "aws_iam_role_policy_attachment" "s3_read_only_policy_attach" {
  role       = aws_iam_role.s3_read_only_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}


# -----------------------------------------------------------------------------
# IAM Role 2: Role for EC2 Stop/Start EventBridge Rule
# This role is assumed by EventBridge to manage EC2 instance state.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_stop_start_role" {
  name = "${var.stage}-ec2-stop-start-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Role 2: EC2 Stop/Start Permissions
resource "aws_iam_policy" "ec2_stop_start_policy" {
  name_prefix = "${var.stage}-ec2-stop-start-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "*" # Specific instances can be narrowed down if needed
      }
    ]
  })
}

# Attach Policy to EC2 Stop/Start Role
resource "aws_iam_role_policy_attachment" "ec2_stop_start_policy_attach" {
  role       = aws_iam_role.ec2_stop_start_role.name
  policy_arn = aws_iam_policy.ec2_stop_start_policy.arn
}

# Data source for current AWS account ID, needed for ARN constructions
data "aws_caller_identity" "current" {}
