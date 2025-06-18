#!/bin/bash
set -e

echo "Starting EC2 bootstrap process..."

# Step 1: Save upload_on_shutdown.sh content
cat << 'EOF' > /usr/local/bin/upload_on_shutdown.sh
${upload_on_shutdown_sh_content}
EOF
chmod +x /usr/local/bin/upload_on_shutdown.sh

# Step 2: Save upload-on-shutdown.service content (renamed for consistency)
cat << 'EOF' > /etc/systemd/system/logupload.service
${upload_on_shutdown_service_content}
EOF

# Step 3: Save verifyrole1a.sh content
cat << 'EOF' > /tmp/verifyrole1a.sh
${verifyrole1a_sh_content}
EOF
chmod +x /tmp/verifyrole1a.sh

# Step 4: Export environment variables
export REPO_URL="${repo_url}"
export S3_BUCKET_NAME="${s3_bucket_name}"
export STAGE="${stage}"
export AWS_REGION="${region}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export INSTANCE_ID=$(ec2-metadata --instance-id | cut -d ' ' -f 2)

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

# Install Docker.io
if ! command -v docker &> /dev/null; then
    echo "--> Installing Docker.io..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu # Add ubuntu user to docker group
else
    echo "--> Docker.io is already installed."
fi
echo "--> AWS CLI, jq, and Docker installation complete."

# Step 6: Create /root/springlog directory
echo "--> Creating /root/springlog directory..."
sudo mkdir -p /root/springlog
echo "--> /root/springlog created."

# Step 7: Clone the Git repository
echo "--> Cloning Git repository: ${REPO_URL} into /root/..."
REPO_NAME=$(basename "${REPO_URL}" .git) # Extract repo name from URL
git clone "${REPO_URL}" /root/"${REPO_NAME}"

# Self-verify the repo directory
if [ -d "/root/${REPO_NAME}" ]; then
    echo "--> Repository /root/${REPO_NAME} cloned successfully."
else
    echo "ERROR: Repository cloning failed."
    exit 1
fi

# Step 8: Inject Dockerfile into the cloned repo directory
echo "--> Injecting Dockerfile into /root/${REPO_NAME}/..."
# This assumes your Terraform setup will copy the Dockerfile to a known location,
# for example, using a templatefile function or file function in Terraform.
# For now, we'll use a placeholder that assumes the Dockerfile content is passed
# as a Terraform variable.
cat << 'EOF' > "/root/${REPO_NAME}/Dockerfile"
${dockerfile_content}
EOF
echo "--> Dockerfile injected."

# Step 9: Add logging configuration to application.properties
echo "--> Adding logging configuration to application.properties..."
APPLICATION_PROPERTIES_PATH="/root/${REPO_NAME}/src/main/resources/application.properties"
echo "logging.file.name=/root/springlog/application.log" | sudo tee -a "${APPLICATION_PROPERTIES_PATH}" > /dev/null
echo "--> Logging configuration added."

# Step 10: Navigate to repo directory, build Docker image, and run container
echo "--> Navigating to /root/${REPO_NAME}/ and performing Docker operations..."
cd "/root/${REPO_NAME}"

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
systemctl enable logupload.service
systemctl start logupload.service
echo "--> Logupload service enabled and started."

echo "EC2 bootstrap process complete."
