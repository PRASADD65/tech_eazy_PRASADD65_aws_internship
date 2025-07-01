# 🚀 AWS Infrastructure Automation with Terraform
**Assignment - 1,2,3**

## 📘 Overview

This project automates the provisioning of key AWS infrastructure components using Terraform. It includes:

- EC2 instance provisioning.
- IAM roles for secure access control.
- Docker containerization environment to build and host the Java Spring Boot Application.
- A private S3 bucket with lifecycle policies.
- Log archival on instance shutdown.
- Structured automation of self on/off on scheduled time using Event Bridge and Lambda function.
- Git Hub CI/CD to automate the process of deploy and destroy the infrastructure.

---

## 🛠 Tools & Technologies

- **Infrastructure as Code**: Terraform  
- **Cloud Provider**: AWS
- **Cloud tools**: EC2, IAM, S3, Cloudwatch Event Bridge, Lambda, Cloud watch, SNS, Grafana, Prometheus
- **Scripts**: Bash (Shell), systemd  
- **CLI Tools**: AWS CLI
- **Containerizaton**: Docker
- **CI/CD Automation**: GitHub Action
---

## 📁 Project Structure

```
tech_eazy_PRASADD65_aws_internship/

   ├── .github
   |     ├── workflows
   |          └── deploy.yml
   |          └── destroy.yml
   ├── build_lambda_zips.sh
   ├── CloudWatchAlarm.tf
   ├── cloudwatcheventrule.tf
   ├── backend.tf
   ├── ec2.tf
   ├── iam.tf
   ├── dev.tfvars
   ├── lambdafunction.tf
   ├── lambdapermission.tf
   ├── output.tf
   ├── s3.tf
   ├── start_instance.py
   ├── start_instance.zip
   ├── stop_instance.py
   ├── stop_instance.zip
   ├── sns.tf
   ├── terraform.tf
   ├── prod.tfvars
   ├── upload-on-shutdown.service
   ├── upload_on_shutdown.sh
   ├── user_data.sh.tpl
   ├── variable.tf
   └── verifyrole1a.sh
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
- Install CloudWatch Agent, Create CloudWatch Agent config and start the CloudWatch Agent.
- Install docker to handle Java Spring Boot app, Grafana, Prometheus containers
- Install all the dependency files for this project.
---

## 🚀 How to Deploy 
# 2 ways to deploy - Manual, CI/CD
**Manual** 

we will have following procedures to perform this assignment:
1. Set IAM permissions if your are using IAM user account. If it is root account, it is not requried.
2. Set up the EC2 to use terraform  and provision the infrastructure.


**1. IAM permissions**
- As a root account user no need to set IAM policies.
- If you are using an IAM user, must provide following IAM policies:
   - Go to IAM console
   - Select the user
   - Add permissions
      - EC2fullaccess
      - Lambdafullaccess
      - S3fullaccess
      - Eventbridgefullaccess
   - For best practice use custom managed policy with inline policies more granular control.
     
**2. EC2**
- I have used EC2 as my terraform handler. So all the process mention here are based performed on EC2 instance:
- Login to your AWS account. Root account or to your IAM user account.
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

### 🔧 Prerequisites
Once we login to the EC2, we have to install the Prerequisites:
 - unzip
 - AWS CLI
 - Configure the AWS region
 - Terraform
---
- Update the ubuntu packages
  ```
  apt update
  ```
- **Unzip** 
  ```
  apt install unzip
  ````
- **AWS CLI**
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
- **Configure the AWS Region**
  ```
  aws configure
  ```
  - Now provide your Access key and Secret access key of your account (Best practice use IAM user).
  - Leave the rest of the configurations region, format as default.
   
- **Install Terraform**
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
git clone <your github repo url>
cd <your github repo dir>
```
## Variables inputs on dev.tfvars / prod.tfvars
- Region (can be vary as per requirement)
- Instance type
- Instance ami ID
- Key name (must available on that region on AWS console)
- stage (prod/dev)
- VPC (Not requried as we are using default VPC)
- S3 bucket name (most important or else terraform will not initilize the infrastructure)
- Github repo URL (pub/pvt) for the terraform provisioned ec2.
- Email ID for SNS topic alart subscriptions
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
terraform validate
```
```
terraform plan
```
```
terraform apply
```
- To destroy the infrastructure
```
terraform destroy
```

## Outputs
- Test your spring boot application:
Open you web browser. search
```
<EC2 public-ip>:80  - wait for some time, as it may take some time to boot the application.
```
```
<EC2 public-ip>:9090  - for Promethus. To monitor the node and the spring app health condition.
```
```
<EC2 public-ip>:3000  - for Grafana. To monitor the node and the spring app health condition.
```
- lambda functions, Eventbridge - <stage>-ec2-start/stop rule to automate the ec2 scheduled start and stop for cost saving.
- A S3 bucket with stage name to store the log when the ec2 will stop with after 7 days log delete Lifecycle policy. 
- To test log upload to s3, stop the EC2 by cron job or manually.
- For quick test manually stop the ec2 and test the S3 bucket - Go to your-bucket - /app/logs/shutdown_logs/application_log_<logid>_shutdown.log
- If in the 1st attempt the logs does not upload to the S3, start your ec2 again and wait until the application boot. Once the application is online, stop the instance and 
  check your S3 bucket.
- On push to main/master or tag like deploy-dev/deploy-prod, trigger workflow.
- Support Stage-Based Deployments to support different stages (e.g., dev, qa, prod).
- Stage parameters can be pass via GitHub Action input. Select dev for development env and prod for production env.
- Private/Public GitHub Config Handling. Support Public/Private Config Sources. dev stage will fetch from a public GitHub repo. prod stage will fetch from a private GitHub 
  repo.
- GitHub Token Handling. For private repo access, read a deploy key from GitHub Actions Secrets. Ensure the key will be passed securely to EC2 or Terraform during provisioning if needed.
- Post-Deployment Health Check. Automatically check that the application is reachable. Poll the frontend on port 80 of EC2's public IP.
- Cloud watch to Stream application logs from EC2 to CloudWatch Logs. You will see two logs ID, ec2-syslog for all the logs of ec2, spring-app-logs for spring application's log with stage name specific. 
- CloudWatch Alarm on error patterns or instance health.
- SNS topic to send email notifications when the app will have ERROR / "Exception.
- Subscribe the SNS subscription to receive the email notifications.
- For test the error email alart manually, ssh into your ec2 and run echo "ERROR: Simulated failure on $(date)" >> /root/springlog/application.log

---

## ⚠️ Notes

- Terraform will **fail** if `bucket_name` is not provided  
- EC2 must have **IAM permissions** to use S3, Lambda, EventBridge 
- EC2 requires **internet access** to install AWS CLI
- EC2 start time - cron(45 22 * * ? *) (As per your requirement)
- EC2 stop time  - cron(45 22 * * ? *)   (As per your requirement)
- Provide the ec2 ami id as per the region
- Provide your email id to receive SNS topic subscription and scuscribe it to receive the email notifications.
- Provide the private key in your GitHub account's secrets in order to access git private repo form prod env.
- Set the public keyson the private GitHub account's Deploy keys in order to ec2 can access this private repo. 
- It might take some time to display the spring boot application on browser. Wait for the EC2 to complete it's initializing process.
- The 1st CI/CD will show you build failed. No need to worry, it is just the health check error of the spring boot application, as the spring boot app takes some time to boot. Rest, all the infrastructre is ready to do it's task. On the further commits the health check error will be reslove and you will see the green check mark.

---

## GitHub Action - CI/CD automation
- Automate the build and destroy the infrastructure.
- Set the AWS credentials in the Repository secrets.
- Set the S3 bucket name for the backend terraform.tfstate file storage in the backend.tf file. This bucket have to prebuild on the cloud before the command terraform apply execute.
- Once you are all set with your codes, push to the github repo.
- Upon push to the github repo with tag like deploy-dev/deploy-prod, trigger workflow. The jobs will be taken care by as following:
   - The job will be build in Github hosted runner (default runner).
   - The .github/workflow/deploy.yml file will be responsible for create the infrastructure.
   - The .github/workflow/destroy.yml file will be responsible for destory the infrastructure.
   - the infrastructures will be managed with different different workspace to maintain the infrastructure as per stage, eg. dev or prod.
   - Set the stage dev/prod on the Run workflow "Deploy in the AWS Infrastructure with Terraform workflow" to deploy the infrastructure.
   - Set the stage dev/prod in the Run workflow in the "Destroy AWS destroy infrastructure workflow" to destroy the infrastructure.
---
 
