output "root_record_id" {
  description = "ID of the root A record"
  value       = digitalocean_record.root.id
}

output "www_record_id" {
  description = "ID of the www A record"
  value       = digitalocean_record.www.id
}

output "api_record_id" {
  description = "ID of the api A record"
  value       = digitalocean_record.api.id
}

output "ai_record_id" {
  description = "ID of the ai A record"
  value       = digitalocean_record.ai.id
}

output "traefik_record_id" {
  description = "ID of the traefik A record"
  value       = digitalocean_record.traefik.id
}

output "all_records" {
  description = "Map of all DNS records created"
  value = {
    root    = digitalocean_record.root.id
    www     = digitalocean_record.www.id
    api     = digitalocean_record.api.id
    ai      = digitalocean_record.ai.id
    traefik = digitalocean_record.traefik.id
  }
}

output "dns_urls" {
  description = "All DNS URLs created"
  value = {
    root    = "https://${var.domain_name}"
    www     = "https://www.${var.domain_name}"
    api     = "https://api.${var.domain_name}"
    ai      = "https://ai.${var.domain_name}"
    traefik = "https://traefik.${var.domain_name}"
  }
}

