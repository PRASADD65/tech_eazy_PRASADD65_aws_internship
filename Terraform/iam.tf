# Get current AWS account ID
data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------
# EC2 Role for S3 Upload (No Read Access)
# -------------------------------------------------------------------
resource "aws_iam_role" "ec2_s3_upload_role" {
  name_prefix        = "${var.stage}-ec2-s3-upload-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.stage}-ec2-s3-upload-role"
  }
}

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

resource "aws_iam_role_policy_attachment" "ec2_s3_upload_policy_attach" {
  role       = aws_iam_role.ec2_s3_upload_role.name
  policy_arn = aws_iam_policy.ec2_s3_upload_policy.arn
}

resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "${var.stage}-app-instance-profile"
  role = aws_iam_role.ec2_s3_upload_role.name

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  depends_on = [aws_iam_role.ec2_s3_upload_role]
}

# -------------------------------------------------------------------
# S3 Read-Only Role (for verification)
# -------------------------------------------------------------------
resource "aws_iam_role" "s3_read_only_role" {
  name_prefix        = "${var.stage}-s3-read-only-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        AWS = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
          aws_iam_role.ec2_s3_upload_role.arn
        ]
      }
    }]
  })

  tags = {
    Name = "${var.stage}-s3-read-only-role"
  }
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name_prefix = "${var.stage}-s3-read-only-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
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
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_only_policy_attach" {
  role       = aws_iam_role.s3_read_only_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# ---------------------------------------
# Add a CloudWatch Logs Policy Resource
# ---------------------------------------
resource "aws_iam_policy" "ec2_cloudwatch_logs_policy" {
  name_prefix = "${var.stage}-ec2-cloudwatch-logs-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.stage}-spring-app-logs:*", # UPDATED
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.stage}-ec2-syslog:*" # UPDATED
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_logs_policy_attach" {
  role       = aws_iam_role.ec2_s3_upload_role.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_logs_policy.arn
}


# -------------------------------------------------------------------
# EventBridge Role for EC2 Start/Stop
# -------------------------------------------------------------------
resource "aws_iam_role" "ec2_stop_start_eventbridge_role" {
  name = "${var.stage}-ec2-stop-start-eventbridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.stage}-ec2-stop-start-eventbridge-role"
  }
}

resource "aws_iam_policy" "ec2_stop_start_eventbridge_policy" {
  name_prefix = "${var.stage}-ec2-stop-start-eventbridge-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["ec2:StartInstances", "ec2:StopInstances"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_stop_start_eventbridge_policy_attach" {
  role       = aws_iam_role.ec2_stop_start_eventbridge_role.name
  policy_arn = aws_iam_policy.ec2_stop_start_eventbridge_policy.arn
}

# -------------------------------------------------------------------
# Lambda Role to Control EC2
# -------------------------------------------------------------------
resource "aws_iam_role" "lambda_ec2_control_role" {
  name = "${var.stage}-lambda-ec2-control-role"
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
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["ec2:StartInstances", "ec2:StopInstances"],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "logs:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_control_policy_attach" {
  role       = aws_iam_role.lambda_ec2_control_role.name
  policy_arn = aws_iam_policy.lambda_ec2_control_policy.arn
}
