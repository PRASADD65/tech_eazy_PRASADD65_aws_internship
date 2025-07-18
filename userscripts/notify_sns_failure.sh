#!/bin/bash
set -e

# Load SNS topic ARN from the file created during userdata bootstrap
SNS_TOPIC_ARN=$(cat /home/ubuntu/snstopic/sns_topic_arn.txt)
SUBJECT="Repo2 Pipeline Failure Alert"

notify_failure() {
  local exit_code=$?
  local failed_command="$BASH_COMMAND"
  local message="🚨 Repo2 Pipeline FAILED

🔹 Job: ${GITHUB_JOB}
🔹 Step: ${STEP_NAME}
🔹 Failed Command: ${failed_command}
🔹 Exit Code: ${exit_code}
🔹 Repo: ${GITHUB_REPOSITORY}
🔹 Run URL: https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

  echo "Sending SNS failure notification..."
  aws sns publish --topic-arn "$SNS_TOPIC_ARN" --subject "$SUBJECT" --message "$message"
  exit $exit_code
}

trap notify_failure ERR

chmod +x scripts/notify_sns_failure.sh
