# 🚀 AWS Infrastructure Automation with Terraform

## 📘 Overview

This project automates the provisioning of key AWS infrastructure components using Terraform. It includes:
- EC2 instance provisioning
- IAM roles for secure access control
- Hosting the spring boot application
- A private S3 bucket with lifecycle policies
- Log archival on instance shutdown
- Structured automation of self on/off on scheuduled time using EventBridge and Lambda function.

---

## 🛠 Tools & Technologies

- **Infrastructure as Code**: Terraform  
- **Cloud Provider**: AWS
- **Cloud tools**: EC2, VPC, IAM, S3, Cloudwatch Event Bridge, Lambda
- **Scripts**: Bash (Shell), systemd  
- **CLI Tools**: AWS CLI
- **Containerizaton**: Docker
---

## 📁 Project Structure

```
tech_eazy_PRASADD65_aws_internship/
├── app/
│   ├── .terraform.lock.hcl
│   ├── Dockerfile
│   ├── build_lambda_zips.sh
│   ├── cloudwatcheventrule.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── lambdafunction.tf
│   ├── lambdapermission.tf
│   ├── output.tf
│   ├── s3.tf
│   ├── start_instance.py
│   ├── start_instance.zip
│   ├── stop_instance.py
│   ├── stop_instance.zip
│   ├── terraform.tf
│   ├── terraform.tfvars
│   ├── upload-on-shutdown.service
│   ├── upload_on_shutdown.sh
│   ├── user_data.sh.tpl
│   ├── variable.tf
│   └── verifyrole1a.sh
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

- `upload_on_shutdown.sh`: Uploads logs to S3  
- `upload_on_shutdown.service`: systemd unit that runs `logupload.sh` on shutdown  
- `user_data.sh.tpl`: To handle all the internal configurations and their functions.

Referenced in Terraform using:  
```hcl
user_data = file("scripts/permission.sh")
```
---

## 🚀 How to Deploy

- I have used EC2 as my terraform handler. So all the process mention here are based performed on EC2 instance:
- Login to your AWS account.
- Create an EC2 instance with Ubuntu  OS on any region.
- ssh into your EC2
  ```
  cd /path/to/your/.pem key file
  ```
  ```
   ssh -i <your .pem keyfile> ubunut@<EC2 public_ip>
  ```
- Switch to root user
  ```
  sudo -i
  ```
---
- ### 🔧 Prerequisites
- Update the ubuntu packages
  ```
  apt update
  ```
  **Unzip** 
  ```
  apt install unzip
  ````
  **AWS CLI**
  - AWS CLI install and update instructions for Linux
  - To install the AWS CLI, run the following commands:
  ```
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
  - To update your current installation
  ```
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  ```
  - Confirm the installation with the following command
  ```
  aws --version
  ```
  - Use the which command to find your symlink. This gives you the path to use with the --bin-dir parameter.
  ```
  which aws
  ```
  **Configure the AWS Region**
  ```
  aws configure
  ```
 - Now provide your Access key and Secret access key of your account (Best practice use IAM user).
 - Leave the rest of the configurations region, format as default.
   
 **Install Terraform**
 - Ubuntu/Debian :
 - HashiCorp's GPG signature and install HashiCorp's Debian package repository
 ```
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
 ```
 - Install the HashiCorp GPG key
 ```
  wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
 ```
 - Verify the key's fingerprint
  ```
  gpg --no-default-keyring \
  keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  fingerprint
 ```
 - Add the official HashiCorp repository to your system. The lsb_release -cs command finds the distribution release codename for your current system, such as buster, groovy, or sid.
 ```
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-     release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
 ```
 - Download the package information from HashiCorp
  ```
  sudo apt update
  ```
 - Install Terraform from the new repository
  ```
  sudo apt-get install terraform
  ```
 - Verify the installation
  ```
  terraform --version
  ```
---
### 🧪 Deployment Steps

```bash
# Clone the repository
git clone https://github.com/PRASADD65/tech_eazy_PRASADD65_aws_internship.git
cd tech_eazy_PRASADD65_aws_internship
```
## Variables inputs on terraform.tfvars
- Region (can be vary as per requirement)
- Instance type
- Key name (must available on that region on AWS console)
- stage (prod/dev)
- VPC CIDR block, subnets range
- S3 bucket name (most important or else terraform will not initilize the infrastructure)
- EC2 start time - in cron job format - (45 22 * * ? *) 
- EC2 stop time - in cron job format - (45 22 * * ? * ) (Cron job formats are should be in UTC time zone, as per EventBridge works on UTC format)
  - Example Scenarios:
    Let's say you want a cron job to run daily at 2:00 PM IST.
    Convert IST to UTC:
    2:00 PM IST - 5 hours 30 minutes = 8:30 AM UTC
  - The cron entry would be:
    ```
    30 8 * * ? *
    ```
- Cron Job Syntax:
A cron entry has five fields for time and date, followed by the command to execute:    
```
┌───────────── min (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
* * * * * command_to_execute
```
---
# Deploy
```
terraform init
```
```
terraform plan
```
```
terraform apply
```

**Output**
- Test your spring boot application:
Open you web browser. search
```
<EC2 public-ip> - wait for some time, as it may take some time to boot the application.
```
- Check your lambda functions, Eventbridge - <stage>-ec2-start/stop rule
- TO test log upload, you can adjust the stop time 
    
## ⚠️ Notes

- Terraform will **fail** if `bucket_name` is not provided  
- EC2 must have **IAM permissions** to access S3  
- EC2 requires **internet access** to install AWS CLI
- EC2 start time - just write - 14:01 (As per your requirement)
- EC2 stop time - write like this - cron(45 22 * * ? *)   (As per your requirement)

---

## 

- 
