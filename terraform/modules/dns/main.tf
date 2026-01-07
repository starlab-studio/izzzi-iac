# ============================================
# DNS Records for IZZZI Application
# ============================================

# Root domain (smoothbill.fr)
resource "digitalocean_record" "root" {
  domain = var.domain_name
  type   = "A"
  name   = "@"
  value  = var.manager_ip
  ttl    = 300
}

# WWW subdomain (www.smoothbill.fr)
resource "digitalocean_record" "www" {
  domain = var.domain_name
  type   = "A"
  name   = "www"
  value  = var.manager_ip
  ttl    = 300
}

# API subdomain (api.smoothbill.fr)
resource "digitalocean_record" "api" {
  domain = var.domain_name
  type   = "A"
  name   = "api"
  value  = var.manager_ip
  ttl    = 300
}

# AI subdomain (ai.smoothbill.fr)
resource "digitalocean_record" "ai" {
  domain = var.domain_name
  type   = "A"
  name   = "ai"
  value  = var.manager_ip
  ttl    = 300
}

# Traefik dashboard (traefik.smoothbill.fr)
resource "digitalocean_record" "traefik" {
  domain = var.domain_name
  type   = "A"
  name   = "traefik"
  value  = var.manager_ip
  ttl    = 300
}

