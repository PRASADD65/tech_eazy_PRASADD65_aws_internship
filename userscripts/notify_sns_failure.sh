#!/bin/bash

# Load SNS topic ARN from the file created during userdata bootstrap
SNS_TOPIC_ARN=$(cat /home/ubuntu/snstopic/sns_topic_arn.txt)
SUBJECT="Repo2 Pipeline Failure Alert"

notify_failure() {
  local exit_code=$?
  local failed_command="$BASH_COMMAND" # $BASH_COMMAND holds the command that failed
  
  # Construct the message with the STAGE variable
  local message="🚨 Repo2 Pipeline FAILED
🔹 Job: ${GITHUB_JOB}
🔹 Stage: ${STAGE} 
🔹 Step: ${STEP_NAME}
🔹 Failed Command: ${failed_command}
🔹 Exit Code: ${exit_code}
🔹 Repo: ${GITHUB_REPOSITORY}
🔹 Run URL: https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

  echo "Sending SNS failure notification..."
  aws sns publish --topic-arn "$SNS_TOPIC_ARN" --subject "$SUBJECT" --message "$message"

  # Do NOT exit here if you want the main workflow to continue or report its own failure
  # If you want the script to immediately exit after sending notification, uncomment:
  # exit $exit_code
}

# Set a trap to call notify_failure on any error (non-zero exit status)
trap 'notify_failure' ERR
