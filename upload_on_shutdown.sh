#!/bin/bash
# upload_on_shutdown.sh
# Uploads the application log to S3 during EC2 instance shutdown.

# Log file for this script's own operations. Crucially, this is set up
# to capture all script output from the very first line.
SHUTDOWN_LOG="/var/log/upload_on_shutdown.log"

# IMPORTANT: Redirect all stdout and stderr of this script to the log file.
# This ensures that even if the script fails early, we capture its attempt.
exec &>> "$SHUTDOWN_LOG"

echo "--- Script started for shutdown log upload ($(date +%Y%m%d_%H%M%S)) ---"

# --- Variables (now sourced from environment) ---
# S3_BUCKET_NAME will be passed as an environment variable from user_data
# LOG_DIR_HOST will be passed as an environment variable from user_data
# Ensure these environment variables are exported by the user data script.

APP_LOG_FILE="${LOG_DIR_HOST}/application.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S_shutdown)
S3_OBJECT_KEY="app/logs/${STAGE}/shutdown_logs/application_log_${TIMESTAMP}.log"

echo "Source Log File: ${APP_LOG_FILE}"
echo "Target S3 Path: s3://${S3_BUCKET_NAME}/${S3_OBJECT_KEY}"

echo "Source Log File: ${APP_LOG_FILE}"
echo "Target S3 Path: s3://${S3_BUCKET_NAME}/${S3_OBJECT_KEY}"

# Check if the log file exists and is not empty before uploading
if [ -s "${APP_LOG_FILE}" ]; then
    echo "Log file exists and is not empty. Proceeding with upload..."
    echo "Running command: /usr/local/bin/aws s3 cp --debug \"${APP_LOG_FILE}\" \"s3://${S3_BUCKET_NAME}/${S3_OBJECT_KEY}\""

    # Execute the AWS S3 copy command with debug output
    /usr/local/bin/aws s3 cp --debug "${APP_LOG_FILE}" "s3://${S3_BUCKET_NAME}/${S3_OBJECT_KEY}"
    UPLOAD_STATUS=$? # Capture exit code of the aws command

    if [ $UPLOAD_STATUS -eq 0 ]; then
        echo "Shutdown log file uploaded successfully."
        # Optional: Clear the log file after successful upload to prevent re-upload of old data
        # > "${APP_LOG_FILE}"
    else
        echo "Error: Failed to upload shutdown log file to S3. AWS CLI exit code: $UPLOAD_STATUS"
        echo "Please check AWS CLI output above for more details."
    fi
else
    echo "Log file (${APP_LOG_FILE}) is empty or does not exist for shutdown upload. Skipping."
fi

echo "-- Shutdown log upload finished ($(date +%Y%m%d_%H%M%S)) --"
