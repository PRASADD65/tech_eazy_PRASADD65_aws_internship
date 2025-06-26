variable "region" {
  description = "Define the region"
  type        = string
}

variable "stage" {
  description = "Deployment stage (dev or prod)"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.micro"
}

# Added instance_name variable
variable "instance_name" {
  description = "Name of the EC2 instance (used in tags)."
  type        = string
  default     = "TechEazy"
}

# Github_repo_url
variable "repo_url" {
  description = "The URL of the Git repository containing the application code."
  type        = string
  default     = "https://github.com/techeazy-consulting/techeazy-devops.git"
}

variable "key_name" {
  description = "The name of the AWS EC2 Key Pair to use for SSH access."
  type        = string
}

variable "s3_bucket_name" {
  description = "The globally unique name for the S3 bucket where logs will be stored."
  type        = string
  # No default here, as it must be explicitly provided and globally unique
}

variable "start_schedule" {
  description = "Cron expression for starting the EC2 instance"
  default     = "cron(55 9 * * ? *)"
}

variable "stop_schedule" {
  description = "Cron expression for stopping the EC2 instance"
  default     = "cron(10 10 * * ? *)"
}
