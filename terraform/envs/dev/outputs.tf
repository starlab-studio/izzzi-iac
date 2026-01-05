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
  value       = "https://api.${var.domain_name}"
}

output "ai_url" {
  description = "AI service URL"
  value       = "https://ai.${var.domain_name}"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "https://${var.domain_name}"
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
      "0" = "cache"
      "1" = "celery_broker"
      "2" = "celery_results"
      "3" = "reserved"
    }
    note = "Redis running on manager node (label: db=true)"
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

