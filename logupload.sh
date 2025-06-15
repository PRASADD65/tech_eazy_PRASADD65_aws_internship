#!/bin/bash
TIMESTAMP=$(date +%F-%H%M)
aws s3 cp /var/log/cloud-init.log s3://your-bucket-name/app/log/cloud-init-$TIMESTAMP.log
