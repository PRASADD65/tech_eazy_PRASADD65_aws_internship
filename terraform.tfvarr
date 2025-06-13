# AWS EC2 Instance Configuration
instance_type = "t3.micro" # You can change this if needed, e.g., "t3.small"
key_name      = "hyd" # <<< IMPORTANT: REPLACE WITH YOUR ACTUAL EC2 KEY PAIR NAME >>>
stage         = "dev"      # Defines the environment/stage

# VPC Network Configuration (usually fine with defaults unless specific network setup is needed)
vpc_cidr_block       = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]

# S3 Bucket and Log Backup Configuration
# <<< IMPORTANT: REPLACE WITH A GLOBALLY UNIQUE S3 BUCKET NAME >>>
# This name MUST be unique across ALL of AWS S3.
s3_bucket_name = "techeazy-project2-buckett"

# Instance Shutdown and Log Backup Schedule (Cron Format)
# <<< IMPORTANT: REPLACE WITH YOUR DESIRED CRON EXPRESSION >>>
# Example: "40 18 * * *" means 18:40 (6:40 PM) UTC every day.
# Example: "0 0 * * *" means Midnight (00:00) UTC every day.
# Example: "0 * * * *" means every hour on the hour.
# Check your instance's timezone or assume UTC for cron.
shutdown_time  = "40 18 * * *"

# Application Repository Configuration
# This is the Git URL for your Spring Boot application's source code.
repo_url       = "https://github.com/techeazy-consulting/techeazy-devops.git"
