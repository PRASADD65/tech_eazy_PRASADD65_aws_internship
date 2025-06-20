#!/bin/bash
set -e

echo "Starting EC2 bootstrap process..."

# Step 1: Save upload_on_shutdown.sh content
cat << 'EOF' > /usr/local/bin/upload_on_shutdown.sh
${upload_on_shutdown_sh_content}
EOF
chmod +x /usr/local/bin/upload_on_shutdown.sh

# Step 2: Save upload-on-shutdown.service content
cat << 'EOF' > /etc/systemd/system/upload-on-shutdown.service
${upload_on_shutdown_service_content}
EOF

# Step 3: Save verifyrole1a.sh content
cat << 'EOF' > /tmp/verifyrole1a.sh
${verifyrole1a_sh_content}
EOF
chmod +x /tmp/verifyrole1a.sh

# Step 4: Export environment variables
# CRITICAL CORRECTION: These template placeholders are now consistently UPPERCASE to match ec2.tf
export REPO_URL="${REPO_URL}"
export S3_BUCKET_NAME="${S3_BUCKET_NAME}"
export STAGE="${STAGE}"
export AWS_REGION="${AWS_REGION}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export INSTANCE_ID=$(ec2-metadata --instance-id | cut -d ' ' -f 2)
export LOG_DIR_HOST="/root/springlog"


# Step 5: Install AWS CLI, jq, and Docker
echo "--> Checking for AWS CLI, jq, and Docker..."
sudo apt-get update -y # Ensure package list is up-to-date

# Install jq
if ! command -v jq &> /dev/null; then
    echo "--> Installing jq..."
    sudo apt-get install -y jq
else
    echo "--> jq is already installed."
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "--> Installing Docker..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io
else
    echo "--> Docker is already installed."
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
echo "--> AWS CLI, jq, and Docker installation complete."


# Step 6: Create /root/springlog directory
echo "--> Creating /root/springlog directory..."
sudo mkdir -p /root/springlog
echo "--> /root/springlog created."


# Step 7: Clone the Git repository
echo "--> Cloning Git repository: ${REPO_URL} into /root/..."
REPO_NAME=$(basename "${REPO_URL}" .git) # This line correctly calculates the repository name
git clone "${REPO_URL}" /root/"$REPO_NAME" # <<< CORRECTED: Uses $REPO_NAME (shell variable)

# Self-verify the repo directory
if [ -d "/root/$REPO_NAME" ]; then # <<< CORRECTED: Uses $REPO_NAME
    echo "--> Repository /root/$REPO_NAME cloned successfully." # <<< CORRECTED: Uses $REPO_NAME
else
    echo "ERROR: Repository cloning failed."
    exit 1
fi


# Step 8: Inject Dockerfile into the cloned repo directory
echo "--> Injecting Dockerfile into /root/$REPO_NAME/..." # <<< CORRECTED: Uses $REPO_NAME
cat << 'EOF' > "/root/$REPO_NAME/Dockerfile" # <<< CORRECTED: Uses $REPO_NAME
${dockerfile_content}
EOF
echo "--> Dockerfile injected."


# Step 9: Add logging configuration to application.properties
echo "--> Adding logging configuration to application.properties..."
APPLICATION_PROPERTIES_PATH="/root/$REPO_NAME/src/main/resources/application.properties"
echo "logging.file.name=/root/springlog/application.log" | sudo tee -a "$APPLICATION_PROPERTIES_PATH" > /dev/null # <-- CHANGE THIS LINE
echo "--> Logging configuration added."



# Step 10: Navigate to repo directory, build Docker image, and run container
echo "--> Navigating to /root/$REPO_NAME/ and performing Docker operations..." # <<< CORRECTED: Uses $REPO_NAME
cd "/root/$REPO_NAME" # <<< CORRECTED: Uses $REPO_NAME

echo "--> Building Docker image 'spring'..."
docker build -t spring .
if [ $? -ne 0 ]; then
    echo "ERROR: Docker image build failed."
    exit 1
fi
echo "--> Docker image 'spring' built successfully."

echo "--> Creating and running Docker container 'c1'..."
docker run -itd --name c1 -p 80:80 --restart always --mount type=bind,source=/root/springlog,target=/root/springlog spring:latest
if [ $? -ne 0 ]; then
    echo "ERROR: Docker container creation/run failed."
    exit 1
fi
echo "--> Docker container 'c1' is running."

# Step 11: Enable and start logupload service
echo "--> Enabling and starting logupload service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable upload-on-shutdown.service
systemctl start upload-on-shutdown.service
echo "--> upload-on-shutdown service enabled and started."

echo "EC2 bootstrap process complete."
