# variable.tf

variable "stage" {
  description = "Deployment stage (dev or prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance (used in tags)."
  type        = string
  default     = "TechEazy" # A sensible default
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name for the VPC (used in tags and resources)."
  type        = string
  default     = "MainVPC" # A sensible default for the VPC name
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# New variable for Availability Zones
variable "azs" {
  description = "A list of availability zones to use for the VPC subnets."
  type        = list(string)
  # It's best to specify these in your terraform.tfvars or derive dynamically
  # Example default, but use data lookup for robustness in real projects.
  default     = ["ap-south-2a", "ap-south-2b"] # <<< IMPORTANT: Change these to match your AWS region's actual AZs, e.g., for ap-south-2 if that's your region. Or fetch dynamically. >>>
}

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

variable "shutdown_time" {
  description = "The cron expression (5 parts: Minute Hour DayOfMonth Month DayOfWeek) for when the EC2 instance should shut down and logs are backed up. E.g., '40 18 * * *' for 6:40 PM daily."
  type        = string
  validation {
    condition     = length(regexall("\\s", var.shutdown_time)) == 4 && length(var.shutdown_time) > 0
    error_message = "Shutdown time must be a 5-part cron expression (e.g., '0 17 * * *')."
  }
}
