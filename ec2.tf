# ec2.tf

resource "aws_instance" "app_instance" {
  ami                         = "ami-07891c5a242abf4bc" # REMEMBER TO REPLACE THIS WITH YOUR REGION'S UBUNTU AMI ID
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  # Attach the IAM Instance Profile to this EC2 instance
  iam_instance_profile = aws_iam_instance_profile.app_instance_profile.name

  # Use the templatefile function to render the user data script
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    # All variables interpolated within user_data.sh.tpl must be passed here.
    repo_url             = var.repo_url             # Passed as 'repo_url'
    s3_bucket_name       = var.s3_bucket_name       # Passed as 's3_bucket_name'
    shutdown_time        = var.shutdown_time        # Passed as 'shutdown_time'
    stage                = var.stage                # Passed as 'stage'
    automate_sh_content  = file("${path.module}/automate.sh") # Pass content of automate.sh
    logs_off_sh_content  = file("${path.module}/logs_off.sh")  # Pass content of logs_off.sh
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
