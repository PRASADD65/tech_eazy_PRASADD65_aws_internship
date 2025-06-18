resource "aws_lambda_function" "start_instance" {
  filename         = "${path.module}/start_instance.zip" # UPDATED: path to project root
  function_name    = "${var.stage}-StartEC2Instance"
  role             = aws_iam_role.lambda_ec2_control_role.arn
  handler          = "start_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/start_instance.zip") # UPDATED: path to project root
  timeout          = 70

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_server.id
    }
  }

  tags = {
    Name  = "${var.stage}-StartEC2Instance"
    Stage = var.stage
  }
}


resource "aws_lambda_function" "stop_instance" {
  filename         = "${path.module}/stop_instance.zip" # UPDATED: path to project root
  function_name    = "${var.stage}-StopEC2Instance"
  role             = aws_iam_role.lambda_ec2_control_role.arn
  handler          = "stop_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/stop_instance.zip") # UPDATED: path to project root
  timeout          = 70

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.app_server.id
    }
  }

  tags = {
    Name  = "${var.stage}-StopEC2Instance"
    Stage = var.stage
  }
}
