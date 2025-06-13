module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stage}-${var.vpc_name}"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-2a", "ap-south-2a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway     = false
  enable_vpn_gateway     = false

  igw_tags = {
    Name = "${var.stage}-${var.vpc_name}-igw"
  }

  tags = {
    Terraform   = "true"
    Environment = var.stage
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = module.vpc.vpc_id

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
    Name = "${var.stage}-${var.vpc_name}-web-sg"
  }
}
