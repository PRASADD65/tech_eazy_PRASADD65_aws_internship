#!/bin/bash
set -uxo pipefail

# Log everything to a file
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "🚀 Starting EC2 bootstrap process..."

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

systemctl enable docker
systemctl start docker
sleep 3

# ---- Install AWS CLI v2 if not present ----
if ! command -v aws &>/dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
fi

# ---- Set Up SSH for Git ----
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Write the private key securely
echo "${EC2_SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

# Add GitHub to known_hosts to avoid authenticity prompt
ssh-keyscan github.com >> /root/.ssh/known_hosts
chmod 644 /root/.ssh/known_hosts

# ---- Clone the Git Repository ----
REPO_NAME=$(basename "${REPO_URL}" .git)
git clone "${REPO_URL}" /root/"${REPO_NAME}"

# ---- Remove the private key after use for security ----
if [ -f /root/.ssh/id_rsa ]; then
  shred -u /root/.ssh/id_rsa
fi

# ---- Set up logging directory ----
mkdir -p /root/springlog
chmod 755 /root/springlog

# ---- Build and Run Spring App ----
cd "/root/${REPO_NAME}"
docker build -t spring .

docker network create monitoring-net

docker run -itd --name spring-app \
  --network monitoring-net \
  -p 80:80 \
  --restart always \
  -v /root/springlog:/root/springlog \
  spring:latest

# ---- Install CloudWatch Agent ----
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# ---- Create CloudWatch Agent Config ----
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/root/springlog/application.log",
            "log_group_name": "spring-app-logs",
            "log_stream_name": "spring-app-instance"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "ec2-syslog",
            "log_stream_name": "syslog-instance"
          }
        ]
      }
    }
  }
}
EOF

# ---- Start CloudWatch Agent ----
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

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
