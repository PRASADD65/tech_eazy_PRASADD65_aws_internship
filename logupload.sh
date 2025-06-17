#!/bin/bash
set -e

# Log upload script
TIMESTAMP=$(date +%F-%H%M)

# Upload cloud-init log
aws s3 cp /var/log/cloud-init.log s3://$S3_BUCKET_NAME/app/logs/cloud-init-$TIMESTAMP.log

# Upload main application log (only if the file exists)
if [ -f "/var/log/app.log" ]; then
    aws s3 cp /var/log/app.log s3://$S3_BUCKET_NAME/app/logs/app-$TIMESTAMP.log
else
    echo "Warning: /var/log/app.log not found, skipping upload."
fi

# Do NOT include aws ec2 stop-instances here. EventBridge handles stopping.
