# region
region = "ap-south-2"


# AWS EC2 Instance Configuration
instance_type = "t3.micro"
key_name      = "hyd" # << IMPORTANT: REPLACE WITH YOUR ACTUAL EC2 KEY PAIR NAME >>
stage         = "prod"      # Defines the environment/stage

# S3 Bucket and Log Backup Configuration
# <<< IMPORTANT: REPLACE WITH A GLOBALLY UNIQUE S3 BUCKET NAME >>>
# This name MUST be unique across ALL of AWS S3.
s3_bucket_name = "techeazy-project2-buckett"

# Instance Schedule (Cron Format)
# These map to 'start_schedule' and 'stop_schedule' in variables.tf
start_schedule = "cron(5 9 * * ? *)" 
stop_schedule  = "cron(15 9 * * ? *)" 

# Application Repository Configuration
# This is the Git URL for your Spring Boot application's source code.
repo_url       = "https://github.com/PRASADD65/techeazy-devops.git"
