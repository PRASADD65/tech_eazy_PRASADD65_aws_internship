resource "aws_cloudwatch_event_rule" "start_rule" {
  name                = "${var.stage}-StartEC2Schedule" # Added stage prefix
  schedule_expression = var.start_schedule

  tags = { # Add tags for better organization
    Name  = "${var.stage}-StartEC2Schedule"
    Stage = var.stage
  }
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_rule.name
  target_id = "${var.stage}-StartEC2Target" # Added stage prefix to target_id
  arn       = aws_lambda_function.start_instance.arn
}


resource "aws_cloudwatch_event_rule" "stop_rule" {
  name                = "${var.stage}-StopEC2Schedule" # Added stage prefix
  schedule_expression = var.stop_schedule

  tags = { # Add tags for better organization
    Name  = "${var.stage}-StopEC2Schedule"
    Stage = var.stage
  }
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_rule.name
  target_id = "${var.stage}-StopEC2Target" # Added stage prefix to target_id
  arn       = aws_lambda_function.stop_instance.arn
}
