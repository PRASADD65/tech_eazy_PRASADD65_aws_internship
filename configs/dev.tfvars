# region
region = "ap-south-1"


# AWS EC2 Instance Configuration
instance_type = "t2.micro"
ami_id = "ami-0f918f7e67a3323f0"
key_name      = "mub" # << IMPORTANT: REPLACE WITH YOUR ACTUAL EC2 KEY PAIR NAME >>
stage         = "dev"      # Defines the environment/stage

# S3 Bucket and Log Backup Configuration
# <<< IMPORTANT: REPLACE WITH A GLOBALLY UNIQUE S3 BUCKET NAME >>>
# This name MUST be unique across ALL of AWS S3.
s3_bucket_name = "dev-techeazy-project2-buckett"

# Instance Schedule (Cron Format)
# These map to 'start_schedule' and 'stop_schedule' in variables.tf
start_schedule = "cron(5 9 * * ? *)" 
stop_schedule  = "cron(15 9 * * ? *)" 

# Application Repository Configuration
# This is the Git URL for your Spring Boot application's source code.
repo_url       = "https://github.com/PRASADD65/techeazy-devops.git"

# Enter the email address for sns subscription
alert_email = "durgap8464@gmail.com"
