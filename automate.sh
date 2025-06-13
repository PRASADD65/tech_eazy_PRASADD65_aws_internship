#!/bin/bash

# This script performs the core automation tasks using global Maven
# and directly running the compiled JAR.
#
# It expects configuration variables like REPO_URL to be set
# by a preceding script which is part of the user_data.

# --- ENVIRONMENT FIXES (kept for robustness, though global Maven is less sensitive) ---
# Ensure HOME environment variable is set as early as possible in the overall user_data script (in ec2.tf).
export HOME=/root

# Explicitly set JAVA_HOME and update PATH for the apt-installed OpenJDK 21.
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

set -e
set -x

echo "################################################################"
echo "# Starting Core Application Setup Script                     #"
echo "# (Executed via Terraform user_data)                         #"
echo "################################################################"

# --- Define dynamic variables from sourced config or provide defaults ---
REPO_URL="${REPO_URL:-https://github.com/techeazy-consulting/techeazy-devops.git}"
REPO_DIR_NAME=$(basename "$REPO_URL" .git)

echo "Using Repository URL: $REPO_URL"
echo "Target directory name: /$REPO_DIR_NAME"
echo ""

# --- Install Dependencies ---
echo "--- Installing Java Development Kit (JDK) 21 ---"
sudo apt update -y
sudo apt install openjdk-21-jdk -y

# Verify Java installation
if command -v java &> /dev/null; then
    echo "Java 21 installed successfully."
    java -version
else
    echo "Error: Java 21 installation failed. Please check for errors."
    exit 1
fi
echo ""

echo "--- Installing Node.js (v20 LTS) and npm ---"
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/nodesource.gpg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update -y
sudo apt install nodejs -y

# Verify Node.js and npm installation
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo "Node.js and npm installed successfully."
    node -v
    npm -v
else
    echo "Error: Node.js and npm installation failed. Please check for errors."
    exit 1
fi
echo ""

# --- Install Global Maven ---
echo "--- Installing Global Maven ---"
sudo apt install maven -y

# Verify Maven installation
if command -v mvn &> /dev/null; then
    echo "Maven installed successfully."
    mvn --version
else
    echo "Error: Maven installation failed. Please check for errors."
    exit 1
fi
echo ""

# --- Clone Git Repository ---
echo "--- Cloning Git Repository ---"
cd /
if [ -d "/$REPO_DIR_NAME" ]; then
    echo "Warning: Directory /$REPO_DIR_NAME already exists. Skipping clone."
else
    git clone "$REPO_URL"
    if [ ! -d "/$REPO_DIR_NAME" ]; then
        echo "Error: Git clone failed or directory /$REPO_DIR_NAME was not created. Exiting."
        exit 1
    fi
    echo "Repository cloned successfully to /$REPO_DIR_NAME"
fi
echo ""

# --- Navigate into Cloned Directory and Build Application ---
echo "--- Building the Application (using global mvn) ---"
cd "/$REPO_DIR_NAME" || { echo "Error: Could not navigate to /$REPO_DIR_NAME. Exiting."; exit 1; }

# Build the project using the globally installed Maven
# This should now work without HOME parameter errors.
mvn clean install

echo "Project build completed successfully."
echo ""

# --- Run the Application (Directly from JAR) ---
echo "--- Running the Application (Directly from JAR) ---"

# Assuming the JAR file is in target/ and follows a standard Spring Boot naming convention
# Example: target/your-artifact-id-0.0.1-SNAPSHOT.jar
# You can get the artifactId from pom.xml or specify it directly.
APP_ARTIFACT_ID="techeazy-devops" # <artifactId> from your pom.xml
APP_VERSION="0.0.1-SNAPSHOT" # <version> from your pom.xml

APP_JAR_NAME="$APP_ARTIFACT_ID-$APP_VERSION.jar"
APP_JAR_PATH="./target/$APP_JAR_NAME"

if [ -f "$APP_JAR_PATH" ]; then
    echo "Found application JAR: $APP_JAR_PATH"
    echo "Starting application in the background..."
    # Running the JAR directly
    nohup java -jar "$APP_JAR_PATH" > /var/log/application.log 2>&1 &
    APP_PID=$!
    echo "Application started with PID: $APP_PID"
else
    echo "Error: Application JAR not found at $APP_JAR_PATH. Cannot start application."
    exit 1
fi

echo "Application started in the background."
echo "Logs can be found in '/var/log/application.log'."
echo "Please wait a few moments for the application to fully start."
echo ""

# --- Final message ---
echo "################################################################"
echo "# Setup Complete!                                            #"
echo "################################################################"
echo "Application deployment script finished. Check instance logs and public IP."

