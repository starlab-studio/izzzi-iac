locals {
  vpc_name = "${var.project_name}-${var.environment}-vpc"
  vpc_description = "VPC for ${var.project_name} ${var.environment} environment"
  
  common_tags = merge(
    var.common_tags,
    {
      Name        = local.vpc_name
      Component   = "networking"
      Resource    = "vpc"
    }
  )
}

resource "digitalocean_vpc" "main" {
  name        = local.vpc_name
  region      = var.region
  ip_range    = var.vpc_cidr
  description = local.vpc_description

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

