# 🚀 AWS Infrastructure Automation with Terraform

## 📘 Overview

This project automates the provisioning of key AWS infrastructure components using Terraform. It includes:
- EC2 instance provisioning
- IAM roles for secure access control
- A private S3 bucket with lifecycle policies
- Log archival on instance shutdown
- Structured automation using shell scripts and systemd

---

## 🛠 Tools & Technologies

- **Infrastructure as Code**: Terraform  
- **Cloud Provider**: AWS
- **Cloud tools**: EC2, VPC, IAM, S3, Cloudwatch Event Bridge, AWS SSM
- **Scripts**: Bash (Shell), systemd  
- **CLI Tools**: AWS CLI
---

## 📁 Project Structure

```
tech_eazy_PRASADD65_aws_internship/
├── README.md
├── automate.sh             - holds the spring boot app deployment
├── ec2.tf                  - holds the ec2 configureation with shell script file inject to it.
├── ec2startssm.tf          - holds the auto start the ec2 on the scheduled cron time.
├── iam.tf                  - holds the IAM configurations providing IAM roles and policies for EC, S3.
├── logupload.service       - to handle the log upload process to S3.
├── logupload.sh            - Upload logs to S3.
├── output.tf               - Outputs
├── permission.sh           - Responsible for AWS CLI on EC2 and other permission for EC2 to execute the shell script files.
├── s3.tf                   - S3 configuration with life cycle policy.
├── terraform.tf            - AWS provider and region configuration.
├── terraform.tfvars        - holds the variables to provide provision the infrastructure.
├── user_data.sh.tpl        - holds the all the shell scripts files attach to ec2 for the task execution.
├── variable.tf             - holds the variable for infrastructure flexibilities.
├── verifyrole1a.sh         - Attach the role 1.a to EC2
├── vpc.tf                  - holds the VPC, subnets, security groups configurations.
└── configs/
```

---

## ✅ Features

---

### 🔐 IAM Roles

- **Role 1.a** – Read-only access to S3  
- **Role 1.b** – Write-only access (create buckets, upload logs)  
- EC2 instance is associated with **Role 1.b** via an **instance profile**

---

### 🖥️ EC2 Instance

- Provisioned with Terraform and configured via `user_data`
- Runs `permission.sh` to:
  - Install `unzip` and AWS CLI
  - Setup `logupload.sh` and `logupload.service`
- On shutdown, `logupload.service` triggers a log upload to S3

---

### 🪣 S3 Bucket

- Created as **private**
- Name is **configurable** through Terraform variables
- Stores:
  - Boot logs (e.g. `/var/log/cloud-init.log`)
  - Application logs (e.g. `/app/logs`)
- Lifecycle rule auto-deletes logs after **7 days**

---

## 📜 Scripts Description

All automation scripts are located in the `scripts/` folder:

- `logupload.sh`: Uploads logs to S3  
- `logupload.service`: systemd unit that runs `logupload.sh` on shutdown  
- `permission.sh`: Installs AWS CLI and configures services

Referenced in Terraform using:  
```hcl
user_data = file("scripts/permission.sh")
```

---

## 🚀 How to Deploy

---

### 🔧 Prerequisites

- Terraform CLI ≥ v1.3.0  
- AWS CLI installed and configured  
- IAM user/role with appropriate permissions  
- SSH key pair for EC2 access

---

### 🧪 Deployment Steps

```bash
# Clone the repository
git clone https://github.com/PRASADD65/tech_eazy_PRASADD65_aws_internship.git
cd tech_eazy_PRASADD65_aws_internship


# Deploy
terraform init
terraform plan
terraform apply
```

## Variables inputs on terraform.tfvars
- Region (can be vary as per requirement)
- Instance type
- Key name (must available on that region on AWS console)
- stage (prod/dev)
- VPC CIDR block, subnets range
- S3 bucket name (most important or else terraform will not initilize the infrastructure)
- EC2 start time (in 24 hour format, Eg. 14:25 )
- EC2 stop time (in cron job format - 45 22 * * ? * - will turn off at 22:45)
---

## ⚠️ Notes

- Terraform will **fail** if `bucket_name` is not provided  
- EC2 must have **IAM permissions** to access S3  
- EC2 requires **internet access** to install AWS CLI
- EC2 start time - just write - 14:01 (As per your requirement)
- EC2 stop time - write like this - cron(45 22 * * ? *)   (As per your requirement)

---

## 

- 
