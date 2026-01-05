locals {
  terraform_state_bucket_name = "${var.project_name}-${var.environment}-terraform-state"
  backups_bucket_name         = "${var.project_name}-${var.environment}-backups"
  assets_bucket_name          = "${var.project_name}-${var.environment}-assets"
  
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      ManagedBy   = "terraform"
      Environment = var.environment
      Component   = "storage"
    }
  )
  
  spaces_regions = {
    fra1 = "fra1"
    ams3 = "ams3"
    nyc3 = "nyc3"
    sgp1 = "sgp1"
    sfo3 = "sfo3"
  }
}

# Terraform State Bucket
resource "digitalocean_spaces_bucket" "terraform_state" {
  name   = local.terraform_state_bucket_name
  region = var.region
  
  # Private ACL for state bucket
  acl = "private"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Backups Bucket
resource "digitalocean_spaces_bucket" "backups" {
  name   = local.backups_bucket_name
  region = var.region
  
  # Private ACL for backups
  acl = "private"
  
  lifecycle {
    prevent_destroy = false
  }
}

# Assets Bucket (conditional)
resource "digitalocean_spaces_bucket" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  name   = local.assets_bucket_name
  region = var.region
  
  # ACL configurable (public-read for CDN or private)
  acl = var.assets_bucket_acl
  
  lifecycle {
    prevent_destroy = false
  }
}

# Note: CORS configuration must be done manually via Digital Ocean API or dashboard
# The provider does not support CORS configuration directly
# Use the allowed_origins variable as reference for manual configuration

