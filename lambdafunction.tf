resource "aws_lambda_function" "start_instance" {
  filename         = "start_instance.zip"
  function_name    = "${var.stage}-StartEC2Instance" # Prefixed with stage
  role             = aws_iam_role.lambda_ec2_control_role.arn # Referencing the correct role from iam.tf
  handler          = "start_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("start_instance.zip")
  timeout          = 70

  # IMPORTANT: Pass the EC2 Instance ID here!
  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_server.id # Assuming your EC2 instance resource is named 'app_server'
    }
  }

  tags = { # Add tags
    Name  = "${var.stage}-StartEC2Instance"
    Stage = var.stage
  }
}


resource "aws_lambda_function" "stop_instance" {
  filename         = "stop_instance.zip"
  function_name    = "${var.stage}-StopEC2Instance" # Prefixed with stage
  role             = aws_iam_role.lambda_ec2_control_role.arn # Referencing the correct role from iam.tf
  handler          = "stop_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("stop_instance.zip")
  timeout          = 70

  # IMPORTANT: Pass the EC2 Instance ID here!
  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_server.id # Assuming your EC2 instance resource is named 'app_server'
    }
  }

  tags = { # Add tags
    Name  = "${var.stage}-StopEC2Instance"
    Stage = var.stage
  }
}
