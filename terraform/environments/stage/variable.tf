variable "project_name" {
  description = "Base name of the project (e.g., snapcart)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "The AWS Availability Zone to deploy into"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}