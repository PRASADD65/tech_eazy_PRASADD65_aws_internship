Here are the **exact steps** you need to follow in **Terraform** for this assignment:

---

### ✅ Terraform Steps Overview

1. **Set Up Terraform Project Directory**

   * Create a folder: `ec2-deployment/`
   * Inside, create:

     * `main.tf`
     * `variables.tf`
     * `outputs.tf`
     * `config/` folder (for `dev_config.json`, `prod_config.json` etc.)

---

2. **Define Provider & AWS Credentials (in `main.tf`)**

   * Use environment variables for AWS access:

     ```bash
     export AWS_ACCESS_KEY_ID=your_key
     export AWS_SECRET_ACCESS_KEY=your_secret
     ```

---

3. **Create Variables (in `variables.tf`)**

   * For:

     * Instance type
     * Stage (Dev/Prod)
     * GitHub repo URL
     * Java version
     * Timeout duration (to auto stop instance)

---

4. **Write EC2 Resource Block (in `main.tf`)**

   * Use user data to:

     * Install Java 19
     * Install `git`, `curl`, etc.
     * Clone repo
     * Use `Stage` to copy correct config
     * Run the app

---

5. **Create Configuration Files (e.g. `dev_config.json`, `prod_config.json`)**

   * Store in a folder
   * Use `Stage` variable to select the correct file via script

---

6. **Add User Data Script (in `main.tf`)**

   * Bash script to:

     * Install packages
     * Clone GitHub repo
     * Run app on port 80
     * Schedule auto-shutdown (e.g., `shutdown +60`)

---

7. **Define Outputs (in `outputs.tf`)**

   * Print public IP of EC2 instance

---

8. **Run Terraform**

   ```bash
   terraform init
   terraform apply -var="stage=Dev"
   ```

---

Let me know when you're ready and I’ll scaffold the files for you.
