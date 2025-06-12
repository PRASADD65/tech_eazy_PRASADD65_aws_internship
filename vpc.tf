module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stage}-${var.vpc_name}"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-2a", "ap-south-2a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "110.6.102/24"]

  enable_nat_gateway   = false
  enable_vpn_gateway   = false

  tags = {
    Terraform   = "true"
    Environment = var.stage
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${var.stage}-${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "${var.stage}-${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = module.vpc.public_subnets[0]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = module.vpc.public_subnets[1]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = module.vpc.private_subnets[0]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = module.vpc.private_subnets[1]
  route_table_id = aws_route_table.public.id
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
