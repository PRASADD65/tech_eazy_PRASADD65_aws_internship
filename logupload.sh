#!/bin/bash
set -e

# Log upload script
TIMESTAMP=$(date +%F-%H%M)
aws s3 cp /var/log/cloud-init.log s3://$S3_BUCKET_NAME/app/logs/cloud-init-$TIMESTAMP.log

# Upload app logs
aws s3 cp /path/to/app/logs/* s3://$S3_BUCKET_NAME/app/logs/

# Stop EC2 instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $AWS_REGION
