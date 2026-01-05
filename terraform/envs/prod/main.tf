locals {
  project_name = "izzzi"
  environment  = "production"
  region       = var.region
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "terraform"
    Team        = "devops"
  }
  
  domain_name = var.domain_name
  
  manager_tags = concat(
    ["db:true"],
    var.manager_tags
  )
}

# Networking - VPC
module "networking" {
  source = "../../modules/networking"

  project_name = local.project_name
  environment  = local.environment
  region       = local.region
  vpc_cidr     = var.vpc_cidr

  common_tags = local.common_tags
}

# Droplets - Docker Swarm
module "droplets" {
  source = "../../modules/droplet"

  project_name = local.project_name
  environment  = local.environment
  region       = local.region
  vpc_id       = module.networking.vpc_id

  # Configuration PRODUCTION: 1 manager + 2 workers
  manager_size = "s-2vcpu-4gb"
  worker_size  = "s-2vcpu-4gb"
  worker_count = 2

  ssh_public_key = var.ssh_public_key
  ssh_key_name   = var.ssh_key_name

  manager_tags = local.manager_tags
  worker_tags  = var.worker_tags

  enable_monitoring = true
  enable_backups    = true  # Backups activés en production
  enable_ipv6       = var.enable_ipv6

  common_tags = local.common_tags
}

# Firewall
module "firewall" {
  source = "../../modules/firewall"

  project_name = local.project_name
  environment  = local.environment
  vpc_cidr     = module.networking.vpc_cidr

  droplet_ids = concat(
    [module.droplets.manager_id],
    module.droplets.worker_ids
  )

  manager_droplet_ids = [module.droplets.manager_id]
  worker_droplet_ids  = module.droplets.worker_ids

  allowed_ssh_ips = var.allowed_ssh_ips

  common_tags = local.common_tags
}

# Note: Module DNS à créer ultérieurement
# module "dns" {
#   source = "../../modules/dns"
#   
#   project_name = local.project_name
#   environment  = local.environment
#   domain_name  = local.domain_name
#   
#   manager_ip = module.droplets.manager_public_ip
#   worker_ips = module.droplets.worker_public_ips
# }

