variable "name" {
  description = "The name of the VPC"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support for the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames for the VPC"
  default     = true
}

variable "azs" {
  description = "The availability zones for the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "The private subnets for the VPC"
  type        = list(string)
}

variable "public_subnets" {
  description = "The public subnets for the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "The database subnets for the VPC"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateway for the VPC"
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway for the VPC"
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Whether to use one NAT gateway per availability zone for the VPC"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for instances in the VPC"
  default     = false
}

variable "manage_default_security_group" {
  description = "Wether to manage the default security group for the VPC"
  default = true
}

variable "default_network_acl_egress" {
type = list(map(string))
  description = "List of maps of egress rules to set on the Default Network ACL"
}

variable "default_network_acl_ingress" {
    type = list(map(string))
  description = "List of maps of ingress rules to set on the Default Network ACL"
}

variable "tags" {
  description = "The tags to apply to resources in the VPC"
  type        = map(string)
}