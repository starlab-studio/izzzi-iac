variable "do_token" {
  description = "Digital Ocean API token for authentication"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
  default     = "izzzi"
}

variable "environment" {
  description = "Environment name (staging, production, etc.)"
  type        = string
  validation {
    condition     = contains(["staging", "production", "dev"], var.environment)
    error_message = "Environment must be one of: staging, production, dev"
  }
}

variable "region" {
  description = "Digital Ocean region for resources deployment (fra1 for Frankfurt or ams3 for Amsterdam)"
  type        = string
  default     = "fra1"
  validation {
    condition     = contains(["fra1", "ams3"], var.region)
    error_message = "Region must be either fra1 (Frankfurt) or ams3 (Amsterdam)"
  }
}

variable "terraform_backend_bucket" {
  description = "Name of the Digital Ocean Spaces bucket for Terraform state storage"
  type        = string
}

variable "terraform_backend_region" {
  description = "Region of the Digital Ocean Spaces bucket for Terraform state storage"
  type        = string
  default     = "fra1"
}

variable "terraform_backend_key" {
  description = "Key/path for the Terraform state file in the Spaces bucket"
  type        = string
}

variable "terraform_backend_endpoint" {
  description = "Endpoint URL for the Digital Ocean Spaces bucket"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "izzzi"
    ManagedBy   = "terraform"
    Environment = ""
  }
}

