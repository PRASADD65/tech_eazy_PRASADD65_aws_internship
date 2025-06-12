resource "aws_instance" "app_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI ID
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnets[0]
  depends_on    = [
    aws_key_pair.my_key,
    module.vpc,
    aws_security_group.web_sg
  ]
  user_data = templatefile("${path.module}/automate.sh.tmpl", {
    config_file = "configs/${local.config_file}"
  })

  tags = {
    Name = "${var.stage}-${var.instance_name}"
  }
}

resource "aws_autoscaling_schedule" "shutdown_schedule" {
  scheduled_action_name = "shutdown-instance"
  min_size              = 0
  max_size              = 0
  desired_capacity      = 0
  recurrence            = "*/15 * * * *" # Cron expression for shutdown every 15 minutes
}
