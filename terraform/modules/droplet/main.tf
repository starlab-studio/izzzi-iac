locals {
  manager_name = "${var.project_name}-${var.environment}-swarm-manager"
  worker_name_prefix = "${var.project_name}-${var.environment}-swarm-worker"
  
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      ManagedBy   = "terraform"
      Environment = var.environment
      Component   = "docker-swarm"
    }
  )
  
  manager_tags = concat(
    [for k, v in local.common_tags : "${lower(k)}:${lower(v)}"],
    ["role:manager", "swarm:manager"],
    [for tag in var.manager_tags : lower(tag)]
  )
  
  worker_tags = concat(
    [for k, v in local.common_tags : "${lower(k)}:${lower(v)}"],
    ["role:worker", "swarm:worker"],
    [for tag in var.worker_tags : lower(tag)]
  )
  
  cloud_init_config = templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = var.ssh_public_key
  })
}

# Try to find existing SSH key
data "digitalocean_ssh_keys" "existing" {
  filter {
    key    = "name"
    values = [var.ssh_key_name]
  }
}

# Create SSH key if it doesn't exist
resource "digitalocean_ssh_key" "main" {
  count      = length(data.digitalocean_ssh_keys.existing.ssh_keys) == 0 ? 1 : 0
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

locals {
  ssh_key_id = length(data.digitalocean_ssh_keys.existing.ssh_keys) > 0 ? data.digitalocean_ssh_keys.existing.ssh_keys[0].id : digitalocean_ssh_key.main[0].id
  ssh_key_fingerprint = length(data.digitalocean_ssh_keys.existing.ssh_keys) > 0 ? data.digitalocean_ssh_keys.existing.ssh_keys[0].fingerprint : digitalocean_ssh_key.main[0].fingerprint
}

# Swarm Manager Node
resource "digitalocean_droplet" "manager" {
  name     = local.manager_name
  image    = var.droplet_image
  region   = var.region
  size     = var.manager_size
  vpc_uuid = var.vpc_id
  
  ssh_keys = [local.ssh_key_id]
  
  user_data = local.cloud_init_config
  
  monitoring = var.enable_monitoring
  backups    = var.enable_backups
  ipv6       = var.enable_ipv6
  
  tags = local.manager_tags
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes = [
      ssh_keys,
    ]
  }
  
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

# Swarm Worker Nodes
resource "digitalocean_droplet" "workers" {
  count    = var.worker_count
  name     = "${local.worker_name_prefix}-${format("%02d", count.index + 1)}"
  image    = var.droplet_image
  region   = var.region
  size     = var.worker_size
  vpc_uuid = var.vpc_id
  
  ssh_keys = [local.ssh_key_id]
  
  user_data = local.cloud_init_config
  
  monitoring = var.enable_monitoring
  backups    = var.enable_backups
  ipv6       = var.enable_ipv6
  
  tags = local.worker_tags
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes = [
      ssh_keys,
    ]
  }
  
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

# Associate droplets with Digital Ocean project (if project_id is provided)
resource "digitalocean_project_resources" "droplets" {
  count   = var.do_project_id != "" ? 1 : 0
  project = var.do_project_id
  resources = concat(
    [digitalocean_droplet.manager.urn],
    [for worker in digitalocean_droplet.workers : worker.urn]
  )
}

