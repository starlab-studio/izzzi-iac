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
  description = "Digital Ocean region for droplets deployment (fra1 for Frankfurt or ams3 for Amsterdam)"
  type        = string
  validation {
    condition     = contains(["fra1", "ams3"], var.region)
    error_message = "Region must be either fra1 (Frankfurt) or ams3 (Amsterdam)"
  }
}

variable "vpc_id" {
  description = "ID of the VPC where droplets will be deployed"
  type        = string
}

variable "manager_size" {
  description = "Droplet size for the Swarm manager node (default: s-2vcpu-4gb)"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "worker_size" {
  description = "Droplet size for Swarm worker nodes (default: s-2vcpu-4gb)"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "worker_count" {
  description = "Number of worker nodes to create (default: 2)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 10
    error_message = "Worker count must be between 1 and 10"
  }
}

variable "ssh_public_key" {
  description = "SSH public key content for droplet access"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Digital Ocean (will be created if it doesn't exist)"
  type        = string
}

variable "manager_tags" {
  description = "Additional tags to apply to the manager node"
  type        = list(string)
  default     = []
}

variable "worker_tags" {
  description = "Additional tags to apply to worker nodes"
  type        = list(string)
  default     = []
}

variable "droplet_image" {
  description = "Droplet image/snapshot to use (default: ubuntu-24-04-x64)"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "enable_monitoring" {
  description = "Enable Digital Ocean monitoring agent (default: true)"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Enable automatic backups (recommended for production, default: false)"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Enable IPv6 support (default: false)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "do_project_id" {
  description = "Digital Ocean project ID to associate droplets with (optional)"
  type        = string
  default     = ""
}

