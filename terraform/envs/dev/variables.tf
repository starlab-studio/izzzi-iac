variable "do_token" {
  description = "Digital Ocean API token for authentication"
  type        = string
  sensitive   = true
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

variable "domain_name" {
  description = "Base domain name for the environment (e.g., smoothbill.fr or dev.smoothbill.fr)"
  type        = string
  default     = "smoothbill.fr"
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

variable "ssh_public_key" {
  description = "SSH public key content for droplet access"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Digital Ocean"
  type        = string
  default     = "izzzi-dev-key"
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed to access SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "manager_tags" {
  description = "Additional tags for the manager node"
  type        = list(string)
  default     = []
}

variable "worker_tags" {
  description = "Additional tags for worker nodes"
  type        = list(string)
  default     = []
}

variable "enable_ipv6" {
  description = "Enable IPv6 support on droplets"
  type        = bool
  default     = false
}

variable "terraform_backend_bucket" {
  description = "Name of the Digital Ocean Spaces bucket for Terraform state storage"
  type        = string
  default     = "izzzi-terraform-state"
}

variable "terraform_backend_region" {
  description = "Region of the Digital Ocean Spaces bucket for Terraform state storage"
  type        = string
  default     = "fra1"
}

variable "terraform_backend_key" {
  description = "Key/path for the Terraform state file in the Spaces bucket"
  type        = string
  default     = "dev/terraform.tfstate"
}

variable "terraform_backend_endpoint" {
  description = "Endpoint URL for the Digital Ocean Spaces bucket"
  type        = string
  default     = "https://fra1.digitaloceanspaces.com"
}

variable "spaces_access_id" {
  description = "Digital Ocean Spaces Access Key ID (for backend configuration)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "spaces_secret_key" {
  description = "Digital Ocean Spaces Secret Access Key (for backend configuration)"
  type        = string
  sensitive   = true
  default     = ""
}

