
resource "aws_instance" "app_instance" {
  ami                         = "ami-07891c5a242abf4bc" # REMEMBER TO REPLACE THIS WITH YOUR REGION'S UBUNTU AMI ID
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data_replace_on_change = true

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
    logupload_service_content = templatefile("${path.module}/logupload.service", {
    s3_bucket_name = var.s3_bucket_name
    }),
    verifyrole1a_sh_content = file("${path.module}/verifyrole1a.sh"),
    region		    = var.region,
    AWS_ACCOUNT_ID = var.accountid
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

