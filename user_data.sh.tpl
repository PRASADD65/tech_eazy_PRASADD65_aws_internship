
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

# Step 2: Save logupload.sh content
cat <<'EOF' > /tmp/logupload.sh
${logupload_sh_content}
EOF
chmod +x /tmp/logupload.sh

# Step 3: Save verifyrole1a.sh content
cat <<'EOF' > /tmp/verifyrole1a.sh
${verifyrole1a_sh_content}
EOF
chmod +x /tmp/verifyrole1a.sh

# Step 4: Save logupload.service content
cat <<'EOF' > /etc/systemd/system/logupload.service
[Unit]
Description=Upload cloud-init log to S3 on shutdown
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target

[Service]
Type=oneshot
ExecStart=/opt/logupload.sh
RemainAfterExit=true

[Install]
WantedBy=halt.target reboot.target shutdown.target
EOF

# Step 5: Export environment variables
export REPO_URL="${repo_url}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export STAGE="${stage}"
export SHUTDOWN_HOUR="${shutdown_hour}"
export AWS_REGION="${region}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"

# Step 6: Install AWS CLI if not available, otherwise update it
if ! command -v unzip &> /dev/null
then
    sudo yum install unzip -y
fi

if ! command -v aws &> /dev/null
then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
fi

# Step 7: Enable the systemd service
sudo systemctl enable logupload.service

# Step 8: Setup cron job for shutdown
echo "0 ${SHUTDOWN_HOUR} * * * root /tmp/logupload.sh" >> /etc/crontab

# Step 9: Run the automate script
echo "Running /tmp/automate.sh..."
/tmp/automate.sh

echo "EC2 bootstrap process completed successfully."
