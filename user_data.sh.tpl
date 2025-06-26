#!/bin/bash
set -e

echo "Starting EC2 bootstrap process..."

# ---- Save Shutdown Scripts and Services ----
cat << 'EOF' > /usr/local/bin/upload_on_shutdown.sh
${upload_on_shutdown_sh_content}
EOF
chmod +x /usr/local/bin/upload_on_shutdown.sh

cat << 'EOF' > /etc/systemd/system/upload-on-shutdown.service
${upload_on_shutdown_service_content}
EOF

cat << 'EOF' > /tmp/verifyrole1a.sh
${verifyrole1a_sh_content}
EOF
chmod +x /tmp/verifyrole1a.sh

# ---- Export Environment Variables ----
export REPO_URL="${REPO_URL}"
export S3_BUCKET_NAME="${S3_BUCKET_NAME}"
export STAGE="${STAGE}"
export AWS_REGION="${AWS_REGION}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export INSTANCE_ID=$(ec2-metadata --instance-id | cut -d ' ' -f 2)
export LOG_DIR_HOST="/root/springlog"

# ---- Install Dependencies ----
apt-get update -y
apt-get install -y jq docker.io unzip git curl

# Install AWS CLI v2 if not present
if ! command -v aws &> /dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
fi

# ---- Set Up Logging Directory ----
mkdir -p /root/springlog

# ---- Clone Repo and Build Spring App Image ----
REPO_NAME=$(basename "${REPO_URL}" .git)
git clone "${REPO_URL}" /root/"$REPO_NAME"

# Inject Dockerfile
cat << 'EOF' > "/root/$REPO_NAME/Dockerfile"
${dockerfile_content}
EOF

# Add log config to application.properties
echo "logging.file.name=/root/springlog/application.log" >> "/root/$REPO_NAME/src/main/resources/application.properties"

cd "/root/$REPO_NAME"
docker build -t spring .

# ---- Create Docker Network ----
docker network create monitoring-net

# ---- Run Spring App Container ----
docker run -itd --name spring-app \
  --network monitoring-net \
  -p 80:80 \
  --restart always \
  -v /root/springlog:/root/springlog \
  spring:latest

# ---- Create Environment File for systemd ----
cat <<EOF > /etc/default/upload_on_shutdown_env
S3_BUCKET_NAME="${S3_BUCKET_NAME}"
LOG_DIR_HOST="/root/springlog"
STAGE="${STAGE}"
EOF

# ---- Enable Shutdown Upload Service ----
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable upload-on-shutdown.service
systemctl start upload-on-shutdown.service

# ---- Set Up Prometheus Configuration ----
mkdir -p /root/monitoring

cat << 'EOF' > /root/monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'spring-app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['spring-app:80']
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
EOF

# ---- Create Grafana Volume ----
docker volume create grafana-storage

# ---- Run Prometheus ----
docker run -d --name prometheus \
  --network monitoring-net \
  -p 9090:9090 \
  -v /root/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  --restart always \
  prom/prometheus

# ---- Run Grafana ----
docker run -d --name grafana \
  --network monitoring-net \
  -p 3000:3000 \
  -v grafana-storage:/var/lib/grafana \
  --restart always \
  grafana/grafana

# ---- Run Node Exporter ----
docker run -d --name node-exporter \
  --network monitoring-net \
  --restart always \
  prom/node-exporter


echo "✅ EC2 bootstrap complete: Spring, Prometheus, Grafana, and Node Exporter are running."
