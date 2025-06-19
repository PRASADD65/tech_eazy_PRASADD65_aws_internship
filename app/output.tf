# Output the ID of the EC2 instance
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id # Assuming 'app_server' is the EC2 instance resource name
}

# Output the Public IP address of the EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip # Assuming 'app_server' is the EC2 instance resource name
}

# Output the Private IP address of the EC2 instance
output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip # Assuming 'app_server' is the EC2 instance resource name
}

# Output the name of the S3 bucket for logs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = aws_s3_bucket.app_logs_bucket.bucket # Assuming 'app_logs_bucket' is the S3 bucket resource name
}

# Output the ARN of the EC2 instance's IAM role (Role 1.b from assignment)
output "ec2_s3_upload_role_arn" { # Renamed output for clarity
  description = "ARN of the EC2 instance's IAM role with S3 upload permissions (Role 1.b)"
  value       = aws_iam_role.ec2_s3_upload_role.arn # Updated to match current iam.tf role name
}

# Output the ARN of the S3 Read-Only IAM role (Role 1.a from assignment)
output "s3_read_only_role_arn" {
  description = "ARN of the read-only S3 IAM role (Role 1.a)"
  value       = aws_iam_role.s3_read_only_role.arn
}

# Output the EC2 Instance Profile ARN
output "instance_profile_arn" {
  description = "ARN of the IAM instance profile attached to EC2"
  value       = aws_iam_instance_profile.app_instance_profile.arn
}

# Output the ARN of the Lambda function for starting the instance
output "start_lambda_function_arn" {
  description = "ARN of the Lambda function for starting the EC2 instance"
  value       = aws_lambda_function.start_instance.arn
}

# Output the ARN of the Lambda function for stopping the instance
output "stop_lambda_function_arn" {
  description = "ARN of the Lambda function for stopping the EC2 instance"
  value       = aws_lambda_function.stop_instance.arn
}

# Output the CloudWatch Event Rule ARN for starting the instance
output "start_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule for starting the EC2 instance"
  value       = aws_cloudwatch_event_rule.start_rule.arn
}

# Output the CloudWatch Event Rule ARN for stopping the instance
output "stop_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule for stopping the EC2 instance"
  value       = aws_cloudwatch_event_rule.stop_rule.arn
}

# Output the selected config file path (if still needed, otherwise can remove)
output "selected_config_file" {
  description = "The configuration file selected based on the stage"
  value       = "${path.module}/configs/${var.stage}_config"
}
