# -------------------------------
# CloudWatch Log Groups
# -------------------------------
resource "aws_cloudwatch_log_group" "spring_app_logs" {
  name              = "${var.stage}-spring-app-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ec2_syslog" {
  name              = "${var.stage}-ec2-syslog"
  retention_in_days = 7
}

# -------------------------------
# CloudWatch Log Metric Filter
# -------------------------------
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.stage}-spring-error-filter"
  log_group_name = aws_cloudwatch_log_group.spring_app_logs.name
  pattern        = "?ERROR ?Exception"

  metric_transformation {
    name      = "${var.stage}-SpringAppErrorCount"
    namespace = "${var.stage}-SpringApp"
    value     = "1"
  }

  depends_on = [aws_cloudwatch_log_group.spring_app_logs]
}

# -------------------------------
# CloudWatch Alarm for App Errors
# -------------------------------
resource "aws_cloudwatch_metric_alarm" "spring_error_alarm" {
  alarm_name          = "${var.stage}-SpringAppErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.stage}-SpringAppErrorCount"
  namespace           = "${var.stage}-SpringApp"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when ${var.stage} Spring app logs contain errors"
  alarm_actions       = [aws_sns_topic.app_alerts.arn]
  ok_actions          = [aws_sns_topic.app_alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = {
    Environment = var.stage
    Application = "${var.stage}-spring-app"
  }
}

# -------------------------------
# CloudWatch Alarm for EC2 Status
# -------------------------------
resource "aws_cloudwatch_metric_alarm" "instance_status_alarm" {
  alarm_name          = "${var.stage}-EC2InstanceStatusCheckFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Alarm when ${var.stage} EC2 instance status check fails"
  alarm_actions       = [aws_sns_topic.app_alerts.arn]
  ok_actions          = [aws_sns_topic.app_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  tags = {
    Environment = var.stage
    Application = "${var.stage}-spring-app"
  }
}
