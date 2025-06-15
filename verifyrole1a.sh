#!/bin/bash
set -e

# Assume the read-only role
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${var.stage}-s3-read-only-role"
SESSION_NAME="ReadOnlySession"
CREDS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME)

# Extract temporary credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

# List objects in the S3 bucket
aws s3 ls s3://${var.s3_bucket_name}/app/logs/
