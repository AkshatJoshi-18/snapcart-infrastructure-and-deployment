# ------------------------------------------------------------------------------
# 1. DATA SOURCES (Dynamic Lookups)
# ------------------------------------------------------------------------------

# Fetch the deployment machine's public IP (for SSH whitelist)
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com" # <--- Forces IPv4
}

# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# 2. NETWORKING MODULE
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/networking/vpc"

  # Best Practice: consistent naming strategy
  # We combine project + env to ensure unique names like "snapcart-prod-vpc"
  project_name      = "${var.project_name}-${var.environment}" 
  
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.public_subnet_cidr
  availability_zone = var.availability_zone
}

# ------------------------------------------------------------------------------
# 3. COMPUTE MODULE
# ------------------------------------------------------------------------------
module "app_server" {
  source = "../../modules/compute/ec2"

  # Inputs from Variables
  project_name  = var.project_name
  environment   = var.environment
  instance_type = var.instance_type

  # Inputs from Module Outputs (Dependency Chain)
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_id

  # Inputs from Data Sources
  ami_id              = data.aws_ami.ubuntu.id
  # Use chomp() to remove the hidden '\n' character
  allowed_cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
}