output "user_pool_id" {
  value       = module.izzzi-user-pool.user_pool_id
  description = "Cognito User Pool ID"
}

output "user_pool_client_id" {
  value       = module.izzzi-user-pool.user_pool_client_id
  description = "Cognito User Pool Client ID"
}

# output "first_instance_id" {
#   value       = module.ec2-first-instance.id
#   description = "First EC2 instance ID"
# }

# output "first_instance_public_ip" {
#   value       = module.ec2-first-instance.public_ip
#   description = "First EC2 public IP"
# }

# output "second_instance_id" {
#   value       = module.ec2-second-instance.id
# }

# output "third_instance_id" {
#   value       = module.ec2-third-instance.id
# }