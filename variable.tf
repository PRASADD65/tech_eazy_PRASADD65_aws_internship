variable "stage" {
  description = "Deployment stage (dev or prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
