terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name # Must be globally unique
    key            = "terraform.tfstate" # This key will be prefixed by workspace name (e.g., devops-project/env:/dev/terraform.tfstate)
    region         = var.region # Your AWS region from terraform.tfvars
  }
}
