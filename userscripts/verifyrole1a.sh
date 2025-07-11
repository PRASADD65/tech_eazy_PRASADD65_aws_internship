#!/bin/bash
set -e

# Assume the read-only role
# AWS_ACCOUNT_ID, STAGE, and S3_BUCKET_NAME are expected to be set as environment variables by user_data.sh.tpl
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${STAGE}-s3-read-only-role"
SESSION_NAME="ReadOnlySession"
CREDS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME)

# Extract temporary credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

# List objects in the S3 bucket
aws s3 ls s3://${S3_BUCKET_NAME}/app/logs/
