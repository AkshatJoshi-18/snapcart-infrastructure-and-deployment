# 1. The "Constraints" Block
terraform {
  required_version = "1.14.3" # Enforce Terraform Core version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0" # CRITICAL: Version Pinning
    }
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
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "snapcart-infrastructure-and-deployment"
    }
  }
}