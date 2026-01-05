terraform {
  backend "s3" {
    endpoint                    = "https://fra1.digitaloceanspaces.com"
    region                      = "fra1"
    bucket                      = "izzzi-terraform-state"
    key                         = "production/terraform.tfstate"
    encrypt                     = true
    skip_credentials_validation = true
    skip_region_validation      = true
    
    # Credentials should be provided via environment variables or backend config
    # access_key = var.spaces_access_id
    # secret_key = var.spaces_secret_key
  }
}

