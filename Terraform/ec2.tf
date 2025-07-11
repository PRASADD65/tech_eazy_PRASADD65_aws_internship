resource "aws_instance" "app_server" {
  ami                         = var.ami_id # Keep your specific AMI ID. Confirm it's valid for your region.
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data_replace_on_change = true

  # Attach the IAM Instance Profile to this EC2 instance
  iam_instance_profile = aws_iam_instance_profile.app_instance_profile.name

  user_data = templatefile("${path.module}/../userscripts/user_data.sh.tpl", {
    REPO_URL                     = var.repo_url,
    S3_BUCKET_NAME               = var.s3_bucket_name,
    STAGE                        = var.stage,
    AWS_REGION                   = var.region,
    AWS_ACCOUNT_ID               = data.aws_caller_identity.current.account_id,
    REPO_NAME                    = trimsuffix(basename(var.repo_url), ".git"),
    EC2_SSH_PRIVATE_KEY = replace(var.ec2_ssh_private_key, "\\n", "\n"),
    upload_on_shutdown_service_content = templatefile("${path.module}/../userscripts/upload-on-shutdown.service", {
      S3_BUCKET_NAME = var.s3_bucket_name,
      STAGE          = var.stage
    }),
    upload_on_shutdown_sh_content = file("${path.module}/../userscripts/upload_on_shutdown.sh"),
    verifyrole1a_sh_content       = file("${path.module}/../userscripts/verifyrole1a.sh"),
  })

  # The explicit self-dependency is NOT needed here anymore for private_ip as it's fetched in user_data.
  # However, keeping other depends_on as per your original file.
  depends_on = [
    aws_security_group.web_sg,
    aws_iam_instance_profile.app_instance_profile # Ensure IAM profile is created before attaching
  ]

  tags = {
    Name  = "${var.stage}-app-server"
    Stage = var.stage
  }

  root_block_device {
    volume_size = 20
  }
}


resource "aws_security_group" "web_sg" {
  name        = "${var.stage}-app-web-sg"
  description = "Allow SSH and HTTP inbound traffic for app server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- Ingress rules for Grafana and Prometheus UIs (from previous step) ---
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # IMPORTANT: Restrict this in production to your IP or known range
    description = "Allow Grafana UI access"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # IMPORTANT: Restrict this in production to your IP or known range
    description = "Allow Prometheus UI access"
  }
  # --- End Ingress Rules ---

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.stage}-app-web-sg"
    Stage = var.stage
  }
}
