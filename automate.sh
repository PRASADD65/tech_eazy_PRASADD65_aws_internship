#!/bin/bash

set -e

echo "========== Updating System =========="
sudo apt update -y
sudo apt install -y curl unzip git

echo "========== Installing Java 21 =========="
cd /opt
sudo mkdir -p /opt/jdk
cd /opt/jdk
sudo wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
sudo tar -xzf jdk-21_linux-x64_bin.tar.gz
sudo rm jdk-21_linux-x64_bin.tar.gz

export JAVA_HOME=/opt/jdk/jdk-21.0.7
export PATH=$JAVA_HOME/bin:$PATH

echo "JAVA_HOME and PATH set"
echo "Java version: $(java --version)"

echo "========== Installing Node.js and npm =========="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"

echo "========== Cloning Git Repository =========="
cd /home/ubuntu
GIT_REPO="https://github.com/techeazy-consulting/techeazy-devops.git"  # GitHub repo url
APP_DIR="techeazy-devops"

if [ -d "$APP_DIR" ]; then
  echo "Repo already cloned. Pulling latest..."
  cd $APP_DIR && git pull
else
  git clone $GIT_REPO
  cd $APP_DIR
fi

echo "========== Building Java App =========="
chmod +x mvnw
./mvnw clean package

echo "========== Running the App on Port 80 =========="
JAR_FILE=$(find target -name "*.jar" | head -n 1)

# Ensure no other service is using port 80
sudo fuser -k 80/tcp || true

# Run the app using sudo to allow port 80
sudo nohup java -jar $JAR_FILE --server.port=80 > app.log 2>&1 &

echo "========== Deployment Complete =========="
echo "App should now be accessible on: http://$(curl -s http://checkip.amazonaws.com)/"
