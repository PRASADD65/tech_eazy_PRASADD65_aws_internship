module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # It's good practice to pin module versions

  name = "${var.stage}-${var.vpc_name}" 
  cidr = var.vpc_cidr_block # Using the variable for VPC CIDR

  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway  = false # Set to true if private subnets need outbound internet access
  enable_vpn_gateway  = false

  tags = {
    Name        = "${var.stage}-${var.vpc_name}-igw" # Adjust tag name for IGW
    Terraform   = "true"
    Environment = var.stage
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.stage}-${var.instance_name}-web-sg" # Adjust name to use instance_name for clarity
  description = "Allow HTTP and SSH access to web instances"
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

  # Egress rule to allow all outbound traffic (common for web servers)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stage}-${var.instance_name}-web-sg"
  }
}
