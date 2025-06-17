#!/bin/bash
set -e

# Log user-data execution
exec &> >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 bootstrap process..."

# Step 1: Save automate.sh content
cat << 'EOF' > /tmp/automate.sh
${automate_sh_content}
EOF
chmod +x /tmp/automate.sh

# Step 2: Save logupload.sh content
cat << 'EOF' > /tmp/logupload.sh
${logupload_sh_content}
EOF
chmod +x /tmp/logupload.sh

# Step 3: Save verifyrole1a.sh content
cat << 'EOF' > /tmp/verifyrole1a.sh
${verifyrole1a_sh_content}
EOF
chmod +x /tmp/verifyrole1a.sh

# Step 4: Save logupload.service content
cat << 'EOF' > /etc/systemd/system/logupload.service
${logupload_service_content}
EOF

# Step 5: Save permission.sh content
cat << 'EOF' > /tmp/permission.sh
${permission_sh_content}
EOF
chmod +x /tmp/permission.sh

# Step 6: Export environment variables
export REPO_URL="${repo_url}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export STAGE="${stage}"
export shutdown_hour="${shutdown_hour}"
export AWS_REGION="${region}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export INSTANCE_ID=$(ec2-metadata --instance-id | cut -d ' ' -f 2)


# Step 7: Install AWS CLI and jq if not available
echo "--> Checking for AWS CLI and jq..."
sudo apt-get update -y # Ensure package list is up-to-date

# Install jq
if ! command -v jq &> /dev/null; then
    echo "--> Installing jq..."
    sudo apt-get install -y jq
else
    echo "--> jq is already installed."
fi

# Install AWS CLI v2
if ! command -v aws &> /dev/null; then
    echo "--> Installing AWS CLI v2..."
    sudo apt-get install -y unzip # unzip is needed for awscli v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    rm -rf aws/
else
    echo "--> AWS CLI v2 is already installed."
fi
echo "--> AWS CLI and jq installation complete."

# Step 8: Enable and start logupload service
cp /tmp/logupload.sh /opt/logupload.sh
chmod +x /opt/logupload.sh
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable logupload.service
systemctl start logupload.service

# Step 9: Run automate.sh
/tmp/automate.sh

# echo "automate.sh executed successfully!"
