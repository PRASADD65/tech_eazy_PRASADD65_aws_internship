variable "stage" {
  description = "Deployment stage (dev or prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "TechEazy"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default        = "VPC"
}

variable "az_name" {
  description = "Name of the az"
  type        = string
  default     = "ap-south-2a"
}

variable "github_repo_url" {
  description = "URL of the GitHub repository"
  type        = string
  default     = "https://github.com/techeazy-consulting/techeazy-devops.git"
}

variable "key_name" {
  description = "Name of the AWS Key Pair to SSH into the instance"
  type        = string
  default     = "hyd"
}


