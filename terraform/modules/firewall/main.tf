locals {
  web_firewall_name       = "${var.project_name}-${var.environment}-fw-web"
  internal_firewall_name  = "${var.project_name}-${var.environment}-fw-internal"
  management_firewall_name = "${var.project_name}-${var.environment}-fw-management"
  
  # Use lowercase format to match droplet tags (Digital Ocean is case-sensitive)
  common_tags = merge(
    {
      project     = var.project_name
      managedby   = "terraform"
      environment = var.environment
    },
    var.common_tags
  )
  
  # Limit to 3 tags to leave room for 2 specific tags (max 5 total)
  limited_common_tags = {
    project     = local.common_tags.project
    managedby   = local.common_tags.managedby
    environment = local.common_tags.environment
  }
}

# Web Firewall - For HTTP/HTTPS traffic
resource "digitalocean_firewall" "web" {
  name = local.web_firewall_name

  # Inbound rules - Web traffic
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Outbound rules - Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Apply to all droplets
  droplet_ids = var.droplet_ids

  tags = concat(
    [for k, v in local.limited_common_tags : "${k}:${v}"],
    ["firewall:web", "type:public"]
  )

  depends_on = [
    digitalocean_tag.common_tags,
    digitalocean_tag.firewall_tags
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Internal Firewall - For Swarm and service communication within VPC
resource "digitalocean_firewall" "internal" {
  name = local.internal_firewall_name

  # Inbound rules - Swarm and services (from VPC only)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "2377"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7946"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "7946"
    source_addresses = [var.vpc_cidr]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "4789"
    source_addresses = [var.vpc_cidr]
  }

  # PostgreSQL - single instance
  inbound_rule {
    protocol         = "tcp"
    port_range       = "5432"
    source_addresses = [var.vpc_cidr]
  }

  # Redis - single instance
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6379"
    source_addresses = [var.vpc_cidr]
  }

  # Outbound rules - Allow all traffic to VPC
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = [var.vpc_cidr]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = [var.vpc_cidr]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = [var.vpc_cidr]
  }

  # Apply to all droplets
  droplet_ids = var.droplet_ids

  tags = concat(
    [for k, v in local.limited_common_tags : "${k}:${v}"],
    ["firewall:internal", "type:private"]
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Management Firewall - For SSH access
resource "digitalocean_firewall" "management" {
  name = local.management_firewall_name

  # Inbound rules - SSH from allowed IPs only
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.allowed_ssh_ips
  }

  # Outbound rules - Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Apply to all droplets
  droplet_ids = var.droplet_ids

  tags = concat(
    [for k, v in local.limited_common_tags : "${k}:${v}"],
    ["firewall:management", "type:admin"]
  )

  lifecycle {
    create_before_destroy = true
  }
}

