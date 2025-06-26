# Data source for current AWS account ID, needed for ARN constructions
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# IAM Role 1.b: EC2 Instance Role for S3 Upload (Create Bucket, Upload, NO Read/Down)
# This role is attached directly to the EC2 instance via an instance profile.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_s3_upload_role" {
  name_prefix        = "${var.stage}-ec2-s3-upload-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
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

# IAM Policy for Role 1.b: S3 Upload Permissions (CreateBucket, PutObject, PutObjectAcl, ListBucket specific)
resource "aws_iam_policy" "ec2_s3_upload_policy" {
  name_prefix = "${var.stage}-ec2-s3-upload-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/app/logs/${var.stage}/shutdown_logs/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::${var.s3_bucket_name}",
        Condition = {
          StringLike = {
            "s3:prefix": "app/logs/${var.stage}/shutdown_logs/*"
          }
        }
      },
      {
        Effect = "Deny",
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectTorrent"
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
  role       = aws_iam_role.ec2_s3_upload_role.name
  policy_arn = aws_iam_policy.ec2_s3_upload_policy.arn
}

# IAM Instance Profile: Connects the EC2 instance to the S3 Upload role (1.b)
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.stage}-app-instance-profile"
  role = aws_iam_role.ec2_s3_upload_role.name
}


# -----------------------------------------------------------------------------
# IAM Role 1.a: Role for Read-Only Access to S3 (for verification)
# This role is for verification purposes, to be assumed by the EC2 instance.
# -----------------------------------------------------------------------------
resource "aws_iam_role" "s3_read_only_role" {
  name_prefix        = "${var.stage}-s3-read-only-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", # Allows your AWS account root to assume (for CLI testing)
            aws_iam_role.ec2_s3_upload_role.arn # Allows the EC2 instance's role to assume this role
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
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts"
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
# IAM Role for EC2 Stop/Start EventBridge Rule 
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_stop_start_eventbridge_role" {
  name               = "${var.stage}-ec2-stop-start-eventbridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${var.stage}-ec2-stop-start-eventbridge-role"
  }
}

resource "aws_iam_policy" "ec2_stop_start_eventbridge_policy" {
  name_prefix = "${var.stage}-ec2-stop-start-eventbridge-policy"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "*" # Can be narrowed down later
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_stop_start_eventbridge_policy_attach" {
  role       = aws_iam_role.ec2_stop_start_eventbridge_role.name
  policy_arn = aws_iam_policy.ec2_stop_start_eventbridge_policy.arn
}

# -----------------------------------------------------------------------------
# IAM Role for Lambda to Control EC2 (from your second snippet)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_ec2_control_role" {
  name               = "${var.stage}-lambda-ec2-control-role" # Added stage prefix
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "${var.stage}-lambda-ec2-control-role"
  }
}

resource "aws_iam_policy" "lambda_ec2_control_policy" {
  name_prefix = "${var.stage}-lambda-ec2-control-policy"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "logs:*",
        Effect   = "Allow",
        Resource = "*" # Consider narrowing this down for production
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_control_policy_attach" {
  role       = aws_iam_role.lambda_ec2_control_role.name
  policy_arn = aws_iam_policy.lambda_ec2_control_policy.arn
}
