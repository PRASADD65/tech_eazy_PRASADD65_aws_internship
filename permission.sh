#!/bin/bash

# Check if unzip is available, if not install it
if ! command -v unzip &> /dev/null
then
    sudo yum install unzip -y
fi

# Install AWS CLI if not available, otherwise update it
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

# Make logupload.sh executable
chmod +x /opt/logupload.sh

# Enable the systemd service
sudo systemctl enable logupload.service
