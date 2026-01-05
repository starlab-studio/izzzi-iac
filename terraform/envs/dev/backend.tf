terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://fra1.digitaloceanspaces.com"
    }
    region = "fra1"
    bucket = "izzzi-terraform-state"
    key    = "dev/terraform.tfstate"
    
    # Digital Ocean Spaces compatibility
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = false
    
    # Credentials should be provided via environment variables or backend config
    # access_key = var.spaces_access_id
    # secret_key = var.spaces_secret_key
  }
}

