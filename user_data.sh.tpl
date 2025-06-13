#!/bin/bash
set -e

# Log user-data execution
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 bootstrap process..."

# Step 1: Save automate.sh content
cat <<'EOF' > /tmp/automate.sh
${automate_sh_content}
EOF
chmod +x /tmp/automate.sh

# Step 2: Save logs_off.sh content
cat <<'EOF' > /tmp/logs_off.sh
${logs_off_sh_content}
EOF
chmod +x /tmp/logs_off.sh

# Step 3: Export environment variables
export REPO_URL="${repo_url}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export STAGE="${stage}"
export SHUTDOWN_TIME="${shutdown_time}"

# Step 4: Run the automate script
echo "Running /tmp/automate.sh..."
/tmp/automate.sh

# Step 5: Cleanup (optional)
# rm /tmp/automate.sh /tmp/logs_off.sh

echo "EC2 bootstrap process completed successfully."
