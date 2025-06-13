
# 1st Assignment for DevOps  
## 🚀 Automate EC2 Deployment with Terraform on AWS

---

### 🛠️ Requirements

- **Tools**:
  - Terraform
  - AWS Console
  - Linux (Ubuntu preferred)

---

### 📁 Terraform Project Structure

```
.
├── terraform.tf         # Provider and region definition
├── vpc.tf               # Default VPC module
├── ec2.tf               # EC2 instance resource
├── variables.tf         # All variable definitions
├── outputs.tf           # Output values
├── automate.sh     # User data script for EC2 provisioning
└── configs/
    ├── dev_config
    └── prod_config      # Environment-specific configurations
```

---

### ⚙️ Shell Script Responsibilities

The `automate.sh.tmpl` script:

1. Installs Java 21
2. Installs Node.js v20 and npm
3. Clones GitHub repository
4. Builds the app using Maven
5. Runs the app (assumes Spring Boot on port 80)

---

### 🚀 Terraform Workflow

```bash
terraform init
terraform validate
terraform plan
terraform apply -var="stage=dev" -var="instance_name=my-app"
```

---

### 📤 Config Selection by Environment Variable

Terraform dynamically selects either `dev_config` or `prod_config` based on the value passed via `-var="stage=..."`.

---

### ✅ Terraform Output on AWS

- Public IP and Private IP visible
- VPC, Subnets, and Security Groups reflect `stage` value
- EC2 tags, names, and network settings applied correctly
- Config file selected (dev_config or prod_config) as per env variable pass 

---

### 🌐 Final Web Output

After provisioning, the application is:

- Built from GitHub repo
- Running on port **8080**
- Accessible via the instance’s **public IP**
- Logs located in `/var/log/application.log`

---

## 📜 Commands Used in `automate.sh`

```bash
export HOME=/root
```
- **Purpose**: Sets the `HOME` environment variable for consistent execution context.

```bash
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
```
- **Purpose**: Specifies the installation directory for Java 21.

```bash
export PATH="$JAVA_HOME/bin:$PATH"
```
- **Purpose**: Adds Java to the system's executable path.

```bash
sudo apt update -y
```
- **Purpose**: Updates the package index.

```bash
sudo apt install openjdk-21-jdk -y
```
- **Purpose**: Installs Java 21.

```bash
sudo apt install nodejs npm -y
```
- **Purpose**: Installs Node.js and npm.

```bash
sudo apt install maven -y
```
- **Purpose**: Installs Apache Maven.

```bash
git clone "$REPO_URL"
```
- **Purpose**: Clones the application repository.

```bash
cd "/$REPO_DIR_NAME"
```
- **Purpose**: Enters the project directory.

```bash
mvn clean install
```
- **Purpose**: Builds the application using Maven.

```bash
nohup java -jar "$APP_JAR_PATH" > /var/log/application.log 2>&1 &
```
- **Purpose**: Runs the app in the background and logs output.

---

