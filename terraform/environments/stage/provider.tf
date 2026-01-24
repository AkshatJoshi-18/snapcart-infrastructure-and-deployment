# 1. The "Constraints" Block
terraform {
  required_version = "1.14.3" # Enforce Terraform Core version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0" # CRITICAL: Version Pinning
    }
  }
  # REMOTE BACKEND: Essential for team collaboration and locking
  # Ensure the S3 bucket and DynamoDB table exist before running init
  backend "s3" {
    bucket = "tf-bucket-8630"
    key    = "compute/ec2/terraform.tfstate"
    region = "ap-south-1"
    # dynamodb_table = "terraform-locks"
    encrypt      = true
    use_lockfile = true
  }
}

# 2. The "Configuration" Block
provider "aws" {
  region = "ap-south-1" # Explicit Region Specification

  # Safety Net: Prevent accidental deployment to wrong account
  allowed_account_ids = ["312530021679"]

  # Best Practice: Auto-tag every resource created by this provider
  default_tags {
    tags = {
      Owner       = "DevOps-Team"
      Environment = "stage"
      ManagedBy   = "Terraform"
      Project     = "snapcart-infrastructure-and-deployment"
    }
  }
}