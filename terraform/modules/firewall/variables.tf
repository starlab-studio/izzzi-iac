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

variable "vpc_cidr" {
  description = "CIDR block of the VPC for internal firewall rules"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block"
  }
}

variable "droplet_ids" {
  description = "List of droplet IDs to apply firewall rules to (all droplets)"
  type        = list(string)
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed to access SSH (default: 0.0.0.0/0 for all)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "manager_droplet_ids" {
  description = "List of manager droplet IDs (for reference, not used in firewall rules directly)"
  type        = list(string)
  default     = []
}

variable "worker_droplet_ids" {
  description = "List of worker droplet IDs (for reference, not used in firewall rules directly)"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

