output "manager_id" {
  description = "ID of the Swarm manager droplet"
  value       = digitalocean_droplet.manager.id
}

output "manager_public_ip" {
  description = "Public IP address of the Swarm manager droplet"
  value       = digitalocean_droplet.manager.ipv4_address
}

output "manager_private_ip" {
  description = "Private IP address of the Swarm manager droplet (within VPC)"
  value       = digitalocean_droplet.manager.ipv4_address_private
}

output "manager_urn" {
  description = "URN (Uniform Resource Name) of the Swarm manager droplet"
  value       = digitalocean_droplet.manager.urn
}

output "worker_ids" {
  description = "List of IDs of the Swarm worker droplets"
  value       = [for worker in digitalocean_droplet.workers : worker.id]
}

output "worker_public_ips" {
  description = "List of public IP addresses of the Swarm worker droplets"
  value       = [for worker in digitalocean_droplet.workers : worker.ipv4_address]
}

output "worker_private_ips" {
  description = "List of private IP addresses of the Swarm worker droplets (within VPC)"
  value       = [for worker in digitalocean_droplet.workers : worker.ipv4_address_private]
}

output "worker_urns" {
  description = "List of URNs of the Swarm worker droplets"
  value       = [for worker in digitalocean_droplet.workers : worker.urn]
}

output "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key used for droplet access"
  value       = local.ssh_key_fingerprint
}

output "ssh_key_id" {
  description = "ID of the SSH key used for droplet access"
  value       = local.ssh_key_id
}

output "all_droplet_ips" {
  description = "Map of all droplet names to their public IPs (for easy reference)"
  value = merge(
    {
      manager = digitalocean_droplet.manager.ipv4_address
    },
    {
      for idx, worker in digitalocean_droplet.workers :
      "worker-${format("%02d", idx + 1)}" => worker.ipv4_address
    }
  )
}

output "all_droplet_private_ips" {
  description = "Map of all droplet names to their private IPs (for VPC communication)"
  value = merge(
    {
      manager = digitalocean_droplet.manager.ipv4_address_private
    },
    {
      for idx, worker in digitalocean_droplet.workers :
      "worker-${format("%02d", idx + 1)}" => worker.ipv4_address_private
    }
  )
}

