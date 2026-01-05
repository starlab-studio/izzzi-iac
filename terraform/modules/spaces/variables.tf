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
  description = "Digital Ocean Spaces region (fra1, ams3, nyc3, sgp1, sfo3)"
  type        = string
  validation {
    condition     = contains(["fra1", "ams3", "nyc3", "sgp1", "sfo3"], var.region)
    error_message = "Region must be one of: fra1, ams3, nyc3, sgp1, sfo3"
  }
}

variable "create_assets_bucket" {
  description = "Whether to create the assets bucket for user uploads (default: false)"
  type        = bool
  default     = false
}

variable "assets_bucket_acl" {
  description = "ACL for the assets bucket (private or public-read, default: private)"
  type        = string
  default     = "private"
  
  validation {
    condition     = contains(["private", "public-read"], var.assets_bucket_acl)
    error_message = "assets_bucket_acl must be either 'private' or 'public-read'"
  }
}

variable "backup_retention_days" {
  description = "Number of days to retain backups before deletion (default: 90)"
  type        = number
  default     = 90
  
  validation {
    condition     = var.backup_retention_days > 0 && var.backup_retention_days <= 365
    error_message = "backup_retention_days must be between 1 and 365"
  }
}

variable "allowed_origins" {
  description = "List of allowed CORS origins for the assets bucket"
  type        = list(string)
  default     = []
}

variable "spaces_access_id" {
  description = "Digital Ocean Spaces Access Key ID (for backend configuration, not created by this module)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "spaces_secret_key" {
  description = "Digital Ocean Spaces Secret Access Key (for backend configuration, not created by this module)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

