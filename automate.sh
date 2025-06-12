#!/bin/bash

# -------------------------------
# Automate EC2 Setup & Deployment
# -------------------------------

# Variables passed from Terraform/template
STAGE="${STAGE:-dev}"                         # Default to dev if not passed
REPO_URL="${https://github.com/techeazy-consulting/techeazy-devops.git}"  # Default GitHub repo if not passed

echo "=== Stage: $STAGE"
echo "=== Repo: $REPO_URL"

# Update and install dependencies
apt update -y
apt install -y wget curl unzip git gnupg software-properties-common

# -------------------------------
# Install Java 21
# -------------------------------
echo "Installing Java 21..."
mkdir -p /opt/jdk
cd /opt/jdk
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
tar -xzf jdk-21_linux-x64_bin.tar.gz
export JAVA_HOME=/opt/jdk/jdk-21.0.7
export PATH=$JAVA_HOME/bin:$PATH

echo "Java Version: $(java --version)"

# -------------------------------
# Install Node.js & npm (LTS)
# -------------------------------
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
echo "Node Version: $(node -v)"
echo "NPM Version: $(npm -v)"

# -------------------------------
# Clone Git Repo
# -------------------------------
cd /home/ubuntu || cd /root
git clone "$REPO_URL" app
cd app || exit 1

# -------------------------------
# Copy Stage Config
# -------------------------------
CONFIG_FILE="configs/${STAGE,,}_config.json"  # lowercase stage
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file $CONFIG_FILE not found!"
  exit 1
fi

cp "$CONFIG_FILE" config.json
echo "✅ Using config: $CONFIG_FILE"

# -------------------------------
# Build and Run App
# -------------------------------

# Java build
./mvnw clean package

# Run app on port 80
JAR_FILE=$(find target -name "*.jar" | head -n 1)

if [ -z "$JAR_FILE" ]; then
  echo "❌ No .jar file found in target/"
  exit 1
fi

# Make sure port 80 is not blocked
fuser -k 80/tcp || true

echo "✅ Starting app..."
nohup java -jar "$JAR_FILE" --server.port=80 > /var/log/app.log 2>&1 &

echo "🎉 App is now running on port 80!"
