locals {
  domain_name = var.domain_name
  prod_domain = local.domain_name
}

output "manager_ip" {
  description = "Public IP address of the Swarm manager node"
  value       = module.droplets.manager_public_ip
}

output "manager_private_ip" {
  description = "Private IP address of the Swarm manager node (within VPC)"
  value       = module.droplets.manager_private_ip
}

output "worker_ips" {
  description = "List of public IP addresses of Swarm worker nodes"
  value       = module.droplets.worker_public_ips
}

output "worker_private_ips" {
  description = "List of private IP addresses of Swarm worker nodes (within VPC)"
  value       = module.droplets.worker_private_ips
}

output "api_url" {
  description = "API URL for the backend service"
  value       = "https://api.${local.prod_domain}"
}

output "ai_url" {
  description = "AI service URL"
  value       = "https://ai.${local.prod_domain}"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "https://${local.prod_domain}"
}

output "database_info" {
  description = "PostgreSQL database information (single instance on manager)"
  value = {
    host     = module.droplets.manager_private_ip
    port     = 5432
    database = "izzzi"
    schemas  = ["public", "ai"]
    note     = "PostgreSQL with pgvector running on manager node (label: db=true)"
  }
}

output "redis_info" {
  description = "Redis information (single instance on manager)"
  value = {
    host = module.droplets.manager_private_ip
    port = 6379
    dbs  = {
      "0" = "cache_backend"
      "1" = "cache_ai"
      "2" = "celery_broker"
      "3" = "celery_results"
    }
    note = "Redis running on manager node (label: db=true)"
  }
}

output "database_connection_string_template" {
  description = "Template for PostgreSQL connection string"
  value       = "postgresql://${var.database_user}:${var.database_password}@${module.droplets.manager_private_ip}:5432/izzzi?schema=public"
  sensitive   = true
}

output "backup_policy" {
  description = "Backup policy details for production environment"
  value = {
    enabled          = true
    frequency       = "weekly"
    retention_days  = 30
    droplet_id      = module.droplets.manager_id
    note            = "Weekly backups enabled on manager node (db=true). Configured via Digital Ocean dashboard or API."
  }
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (approximate)"
  value = {
    manager = {
      size        = "s-2vcpu-4gb"
      cost_usd    = "24.00"
      backups_usd = "4.80"
      total_usd   = "28.80"
    }
    workers = {
      count     = 2
      size      = "s-2vcpu-4gb"
      cost_usd  = "48.00"
    }
    total_droplets_usd = "76.80"
    vpc_usd            = "0.00"
    firewall_usd       = "0.00"
    monitoring_usd     = "0.00"
    estimated_total_usd = "76.80"
    note = "Costs are approximate and may vary. Does not include bandwidth, Spaces, or other services."
  }
}

output "ssh_command" {
  description = "SSH command to connect to the manager node"
  value       = "ssh deploy@${module.droplets.manager_public_ip}"
}

output "swarm_init_command" {
  description = "Command to initialize Docker Swarm on the manager"
  value       = "docker swarm init --advertise-addr ${module.droplets.manager_private_ip}"
}

output "swarm_join_command_placeholder" {
  description = "Placeholder for worker join command (run on manager to get actual token)"
  value       = "docker swarm join-token worker"
}

output "vpc_info" {
  description = "VPC information"
  value = {
    id   = module.networking.vpc_id
    cidr = module.networking.vpc_cidr
    name = module.networking.vpc_name
  }
}

output "firewall_info" {
  description = "Firewall information"
  value = {
    web        = module.firewall.web_firewall_id
    internal   = module.firewall.internal_firewall_id
    management = module.firewall.management_firewall_id
  }
}

output "all_droplet_ips" {
  description = "Map of all droplet names to their public IPs"
  value       = module.droplets.all_droplet_ips
}

output "all_droplet_private_ips" {
  description = "Map of all droplet names to their private IPs (VPC)"
  value       = module.droplets.all_droplet_private_ips
}

output "security_info" {
  description = "Security configuration information"
  value = {
    ssh_restricted     = true
    allowed_ssh_ips    = var.allowed_ssh_ips
    backups_enabled    = true
    monitoring_enabled = true
    note               = "SSH access restricted to specific IPs. Backups enabled on manager node."
  }
}

