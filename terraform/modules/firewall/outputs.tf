output "web_firewall_id" {
  description = "ID of the web firewall (HTTP/HTTPS traffic)"
  value       = digitalocean_firewall.web.id
}

output "web_firewall_name" {
  description = "Name of the web firewall"
  value       = digitalocean_firewall.web.name
}

output "internal_firewall_id" {
  description = "ID of the internal firewall (Swarm and service communication)"
  value       = digitalocean_firewall.internal.id
}

output "internal_firewall_name" {
  description = "Name of the internal firewall"
  value       = digitalocean_firewall.internal.name
}

output "management_firewall_id" {
  description = "ID of the management firewall (SSH access)"
  value       = digitalocean_firewall.management.id
}

output "management_firewall_name" {
  description = "Name of the management firewall"
  value       = digitalocean_firewall.management.name
}

output "all_firewall_ids" {
  description = "List of all firewall IDs"
  value = [
    digitalocean_firewall.web.id,
    digitalocean_firewall.internal.id,
    digitalocean_firewall.management.id
  ]
}

