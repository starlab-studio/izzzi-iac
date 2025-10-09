# Elastic container registry module
# module "ecr-frontend" {
#   source = "../../modules/ecr"

#   name                 = "izzzi-frontend"
#   image_tag_mutability = "MUTABLE"
#   scan_on_push         = true
# }

# VPC module
# module "vpc-prod" {
#   source = "../../modules/vpc"

#   name                          = "izzzi-prod-vpc"
#   cidr                          = "10.0.0.0/16"
#   azs                           = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
#   private_subnets               = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets                = ["10.0.101.0/24"]
#   database_subnets              = ["10.0.201.0/24", "10.0.202.0/24"]
#   enable_nat_gateway            = true
#   single_nat_gateway            = true
#   one_nat_gateway_per_az        = false
#   map_public_ip_on_launch       = false
#   manage_default_security_group = true
#   default_network_acl_egress    = []
#   default_network_acl_ingress   = []
#   tags = {
#     Environment = "prod"
#     Name        = "izzzi-prod-vpc"
#   }
# }

# # First EC2 instance
# module "ec2-first-instance" {
#   source = "../../modules/ec2"

#   ami                    = "ami-0d8c6c2b092ebb980"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [module.vpc-prod.default_security_group_id]
#   subnet_id              = module.vpc-prod.private_subnets[0]
#   user_data              = file("user-data.sh")
#   tags = {
#     Environment = "prod"
#     Name        = "izzzi-prod-first-instance"
#   }
# }

# # Second EC2 instance
# module "ec2-second-instance" {
#   source = "../../modules/ec2"

#   ami                    = "ami-0d8c6c2b092ebb980"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [module.vpc-prod.default_security_group_id]
#   subnet_id              = module.vpc-prod.private_subnets[1]
#   user_data              = file("user-data.sh")
#   tags = {
#     Environment = "prod"
#     Name        = "izzzi-prod-second-instance"
#   }
# }

# # Third EC2 instance
# module "ec2-third-instance" {
#   source = "../../modules/ec2"

#   ami                    = "ami-0d8c6c2b092ebb980"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [module.vpc-prod.default_security_group_id]
#   subnet_id              = module.vpc-prod.private_subnets[2]
#   user_data              = file("user-data.sh")
#   tags = {
#     Environment = "prod"
#     Name        = "izzzi-prod-third-instance"
#   }
# }

# User Pool
module "izzzi-user-pool" {
  source = "../../modules/user_pool"

  name = "izzzi-user-pool"

  identity_providers = {
    Google = {
      provider_type = "Google"
      provider_details = {
        client_id        = var.google_client_id
        client_secret    = var.google_client_secret
        authorize_scopes = "email"
      }
      attribute_mapping = {
        email = "email"
      }
    }
  }
}