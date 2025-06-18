resource "aws_lambda_function" "start_instance" {
  filename         = "${path.module}/lambda_code/start_instance.zip" 
  function_name    = "${var.stage}-StartEC2Instance"
  role             = aws_iam_role.lambda_ec2_control_role.arn
  handler          = "start_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_code/start_instance.zip") 
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
  filename         = "${path.module}/lambda_code/stop_instance.zip"
  function_name    = "${var.stage}-StopEC2Instance"
  role             = aws_iam_role.lambda_ec2_control_role.arn
  handler          = "stop_instance.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_code/stop_instance.zip")
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
