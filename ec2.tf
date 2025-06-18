resource "aws_instance" "app_server" {
  ami                         = "ami-07891c5a242abf4bc" # Keep your specific AMI ID. Confirm it's valid for your region.
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true 
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data_replace_on_change = true

  # Attach the IAM Instance Profile to this EC2 instance
  iam_instance_profile = aws_iam_instance_profile.app_instance_profile.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    repo_url                      = var.repo_url,
    s3_bucket_name                = var.s3_bucket_name,
    stage                         = var.stage,
    upload_on_shutdown_service_content = file("${path.module}/systemd/upload-on-shutdown.service"),
    verifyrole1a_sh_content     = file("${path.module}/verifyrole1a.sh"),
    region                        = var.region,
    AWS_ACCOUNT_ID                = data.aws_caller_identity.current.account_id # UPDATED: Fetching account ID dynamically
  })
  depends_on = [
    aws_security_group.web_sg,
    aws_iam_instance_profile.app_instance_profile # Ensure IAM profile is created before attaching
  ]

  tags = {
    Name  = "${var.stage}-app-server" 
    Stage = var.stage                 # Added Stage tag as per our common practice
  }

  root_block_device { # Added this block for explicit volume size, good practice
    volume_size = 20 # Default to 20GB, adjust as needed
  }
}

# New: Data source to get the current AWS Account ID dynamically
data "aws_caller_identity" "current" {}
