output "vpc_id" {
  description = "ID of the created VPC"
  value       = digitalocean_vpc.main.id
}

output "vpc_urn" {
  description = "URN (Uniform Resource Name) of the created VPC"
  value       = digitalocean_vpc.main.urn
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC"
  value       = digitalocean_vpc.main.ip_range
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = digitalocean_vpc.main.name
}

output "vpc_region" {
  description = "Region where the VPC is deployed"
  value       = digitalocean_vpc.main.region
}

