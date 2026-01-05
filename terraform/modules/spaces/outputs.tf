output "terraform_state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = digitalocean_spaces_bucket.terraform_state.name
}

output "terraform_state_bucket_urn" {
  description = "URN (Uniform Resource Name) of the Terraform state bucket"
  value       = digitalocean_spaces_bucket.terraform_state.urn
}

output "terraform_state_bucket_endpoint" {
  description = "Endpoint URL for the Terraform state bucket"
  value       = digitalocean_spaces_bucket.terraform_state.bucket_domain_name
}

output "backups_bucket_name" {
  description = "Name of the backups bucket"
  value       = digitalocean_spaces_bucket.backups.name
}

output "backups_bucket_urn" {
  description = "URN of the backups bucket"
  value       = digitalocean_spaces_bucket.backups.urn
}

output "backups_bucket_endpoint" {
  description = "Endpoint URL for the backups bucket"
  value       = digitalocean_spaces_bucket.backups.bucket_domain_name
}

output "assets_bucket_name" {
  description = "Name of the assets bucket (empty string if not created)"
  value       = var.create_assets_bucket ? digitalocean_spaces_bucket.assets[0].name : ""
}

output "assets_bucket_urn" {
  description = "URN of the assets bucket (empty string if not created)"
  value       = var.create_assets_bucket ? digitalocean_spaces_bucket.assets[0].urn : ""
}

output "assets_bucket_endpoint" {
  description = "Endpoint URL for the assets bucket (empty string if not created)"
  value       = var.create_assets_bucket ? digitalocean_spaces_bucket.assets[0].bucket_domain_name : ""
}

output "spaces_access_id" {
  description = "Digital Ocean Spaces Access Key ID (from variable, for backend configuration)"
  value       = var.spaces_access_id
  sensitive   = true
}

output "spaces_secret_key" {
  description = "Digital Ocean Spaces Secret Access Key (from variable, for backend configuration)"
  value       = var.spaces_secret_key
  sensitive   = true
}

output "spaces_endpoint" {
  description = "Digital Ocean Spaces endpoint URL for the region"
  value       = "https://${var.region}.digitaloceanspaces.com"
}

