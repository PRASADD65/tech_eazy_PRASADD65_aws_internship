#!/bin/bash

# logs_off.sh
# This script is executed by a cron job to backup logs to S3 and then shut down the EC2 instance.

set -e # Exit immediately if a command exits with a non-zero status
set -x # Print commands and their arguments as they are executed

LOG_FILE="/var/log/logs_off.log" # Dedicated log for this script
exec > >(tee -a "$LOG_FILE") 2>&1 # Redirect all output to log file and stdout/stderr

echo "--------------------------------------------------------"
echo "Logs Off Script Started: $(date)"
echo "--------------------------------------------------------"

# --- Define Variables (passed from cron environment or default) ---
# S3_BUCKET_NAME and REPO_DIR_NAME are now passed as env vars via cron.
# Fallback to a default if they aren't somehow passed (shouldn't happen with cron setup below).
S3_BUCKET_NAME="${S3_BUCKET_NAME:-DEFAULT_S3_BUCKET}"
REPO_DIR_NAME="${REPO_DIR_NAME:-techeazy-devops}" # Default from previous project

echo "S3_BUCKET_NAME (from cron env): $S3_BUCKET_NAME"
echo "REPO_DIR_NAME (from cron env): $REPO_DIR_NAME"

# Check if AWS CLI is installed (should be by automate.sh, but safety check)
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not found. Cannot proceed with S3 backup. Terminating script without shutdown."
    exit 1
fi

# --- Log Backup Function ---
backup_logs_to_s3() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local log_archive_name="${HOSTNAME}_logs_backup_${timestamp}.tar.gz" # Include hostname for uniqueness
    local s3_path="s3://${S3_BUCKET_NAME}/app/logs/${log_archive_name}"

    echo "Starting log backup to S3 at ${s3_path}..."

    local ec2_log_path="/var/log/cloud-init-output.log"
    local app_log_path="/var/log/application.log" # As per automate.sh, application.log is here

    local log_files_to_archive=""
    if [ -f "${ec2_log_path}" ]; then
        log_files_to_archive+=" ${ec2_log_path}"
        echo "Found cloud-init-output.log"
    fi
    if [ -f "${app_log_path}" ]; then
        log_files_to_archive+=" ${app_log_path}"
        echo "Found application.log"
    fi

    if [ -z "$log_files_to_archive" ]; then
        echo "No relevant log files found to archive. Skipping backup."
        return 0 # Consider this a success if no logs were found
    fi

    echo "Archiving log files: $log_files_to_archive"
    # Create a compressed tar archive of the specified log files
    # Use -P to preserve leading slashes (absolute paths) in the archive.
    tar -czf /tmp/${log_archive_name} ${log_files_to_archive}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create log archive /tmp/${log_archive_name}. Aborting backup."
        return 1
    fi
    echo "Log archive created: /tmp/${log_archive_name}"

    # Upload the archive to S3
    aws s3 cp /tmp/${log_archive_name} "${s3_path}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to upload /tmp/${log_archive_name} to S3. Aborting backup."
        rm -f /tmp/${log_archive_name} # Clean up local archive
        return 1
    fi
    echo "Log archive successfully uploaded to S3."

    # Clean up local archive after successful upload
    rm -f /tmp/${log_archive_name}
    echo "Local archive /tmp/${log_archive_name} removed."
    return 0 # Success
}

# --- Perform Backup ---
if backup_logs_to_s3; then
    echo "Log backup completed successfully. Proceeding with shutdown."
    # --- Initiate Shutdown ---
    echo "Initiating EC2 instance shutdown at $(date)..."
    sudo shutdown -h now
else
    echo "Log backup failed. EC2 instance will NOT shut down."
    exit 1 # Exit with error to indicate backup failure
fi

echo "--------------------------------------------------------"
echo "Logs Off Script Finished: $(date)"
echo "--------------------------------------------------------"
