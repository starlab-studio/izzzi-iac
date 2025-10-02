module "this" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.3.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  map_public_ip_on_launch = var.map_public_ip_on_launch
  manage_default_security_group = var.manage_default_security_group
  default_network_acl_egress = var.default_network_acl_egress
  default_network_acl_ingress = var.default_network_acl_ingress

  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = var.tags
}