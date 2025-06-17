
# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = ["ap-south-2a", "ap-south-2b"]
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = "${var.stage}-vpc"
  }
}

# -----------------------------------------------------------------------------
# Security Group for EC2
# -----------------------------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "${var.stage}-${var.instance_name}-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stage}-${var.instance_name}-sg"
  }
}
