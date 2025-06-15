resource "aws_ssm_document" "start_ec2" {
  name          = "start-ec2"
  document_type = "Automation"
  content = <<EOF
{
  "schemaVersion": "0.3",
  "description": "Start EC2 instance",
  "parameters": {
    "InstanceId": {
      "type": "String",
      "description": "EC2 Instance ID",
      "default": "${aws_instance.app_instance.id}"
    }
  },
  "mainSteps": [
    {
      "action": "aws:changeInstanceState",
      "name": "startInstance",
      "inputs": {
        "InstanceId": "{{ InstanceId }}",
        "State": "running"
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "start_ec2" {
  name                = "start-ec2"
  schedule_expression = var.startup_cron
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2.name
  target_id = "startEC2"
  arn       = aws_ssm_document.start_ec2.arn
  role_arn  = aws_iam_role.ec2_start_role.arn
}

resource "aws_iam_role" "ec2_start_role" {
  name = "${var.stage}-ec2-start-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_start_policy" {
  name = "${var.stage}-ec2-start-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_start_policy_attachment" {
  role       = aws_iam_role.ec2_start_role.name
  policy_arn = aws_iam_policy.ec2_start_policy.arn
}
