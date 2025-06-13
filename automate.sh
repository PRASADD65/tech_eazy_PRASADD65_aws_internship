#!/bin/bash

# automate.sh
# This script performs the core automation tasks for application setup:
# - Installing Java, Node.js, and Maven
# - Cloning the Git repository
# - Building and running the application
#
# It expects necessary variables (REPO_URL) to be passed as environment variables
# from the user_data script.

# --- IMPORTANT ENVIRONMENT FIXES (kept for robustness) ---
export HOME=/root
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

set -e # Exit immediately if a command exits with a non-zero status
set -x # Print commands and their arguments as they are executed

echo "################################################################"
echo "# Starting Core Application Setup Script                     #"
echo "# (Executed via Terraform user_data)                         #"
echo "################################################################"

# --- Define Variables (passed as environment variables from user_data) ---
# REPO_URL should be available from the parent shell.
# REPO_DIR_NAME can be derived here.

# Extract repository directory name from the URL
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
mvn clean install

echo "Project build completed successfully."
echo ""

# --- Run the Application (Directly from JAR) ---
echo "--- Running the Application (Directly from JAR) ---"

# Assuming the JAR file is in target/ and follows a standard Spring Boot naming convention
APP_ARTIFACT_ID="techeazy-devops" # <artifactId> from your pom.xml
APP_VERSION="0.0.1-SNAPSHOT" # <version> from your pom.xml

APP_JAR_NAME="$APP_ARTIFACT_ID-$APP_VERSION.jar"
APP_JAR_PATH="./target/$APP_JAR_NAME"

if [ -f "$APP_JAR_PATH" ]; then
    echo "Found application JAR: $APP_JAR_PATH"
    echo "Starting application in the background..."
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

# --- Final message for automate.sh ---
echo "################################################################"
echo "# Application Setup Complete!                                #"
echo "################################################################"
