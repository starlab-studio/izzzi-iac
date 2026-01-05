variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

variable "environment" {
  description = "Environment name (staging, production, dev)"
  type        = string
  validation {
    condition     = contains(["staging", "production", "dev"], var.environment)
    error_message = "Environment must be one of: staging, production, dev"
  }
}

variable "region" {
  description = "Digital Ocean region for VPC deployment (fra1 for Frankfurt or ams3 for Amsterdam)"
  type        = string
  validation {
    condition     = contains(["fra1", "ams3"], var.region)
    error_message = "Region must be either fra1 (Frankfurt) or ams3 (Amsterdam)"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (default: 10.10.0.0/16)"
  type        = string
  default     = "10.10.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block"
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

