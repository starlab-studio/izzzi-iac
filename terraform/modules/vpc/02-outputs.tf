output "name" {
  description = "The name of the VPC specified as argument to this module"
  value = module.this.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value = module.this.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value = module.this.vpc_arn
}

output "private_subnets" {
  description = "List of  IDs of private subnets"
  value = module.this.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = module.this.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value = module.this.database_subnets
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value = module.this.private_route_table_ids
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value = module.this.public_route_table_ids
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value = module.this.private_route_table_association_ids
}

output "public_route_table_association_ids" {
  description = "	List of IDs of the public route table association"
  value = module.this.public_route_table_association_ids
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value = module.this.private_network_acl_id
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value = module.this.public_network_acl_id
}