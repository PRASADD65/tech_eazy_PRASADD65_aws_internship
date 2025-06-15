
resource "aws_instance" "app_instance" {
  ami                         = "ami-07891c5a242abf4bc" # REMEMBER TO REPLACE THIS WITH YOUR REGION'S UBUNTU AMI ID
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  # Attach the IAM Instance Profile to this EC2 instance
  iam_instance_profile = aws_iam_instance_profile.app_instance_profile.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    repo_url                = var.repo_url,
    s3_bucket_name          = var.s3_bucket_name,
    shutdown_hour           = var.shutdown_hour,
    stage                   = var.stage,
    automate_sh_content     = file("${path.module}/automate.sh"),
    logupload_sh_content    = file("${path.module}/logupload.sh"),
    permission_sh_content   = file("${path.module}/permission.sh"),
    logupload_service_content = file("${path.module}/logupload.service"),
    verifyrole1a_sh_content = file("${path.module}/verifyrole1a.sh"),
    region                  = var.region
  })

  depends_on = [
    module.vpc,
    aws_security_group.web_sg,
    aws_iam_instance_profile.app_instance_profile # Ensure IAM profile is created before attaching
  ]

  tags = {
    Name = "${var.stage}-${var.instance_name}"
  }
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

  depends_on = [aws_ssm_document.start_ec2]
}
