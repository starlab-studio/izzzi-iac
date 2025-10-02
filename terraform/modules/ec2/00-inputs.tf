variable "ami" {
  type = string
  description = "The AMI to use for the instance"
}

variable "instance_type" {
  type = string
  description = "The instance type to use for the instance"
}

variable "availability_zone" {
  type = string
  description = "The availability zone to use for the instance"
}

variable "user_data" {
  type = string
  description = "The user data to use for the instance"
}

variable "tags" {
  type = map(string)
  description = "The tags to apply to the instance"
}

variable "subnet_id" {
  type = string
  description = "The subnet ID to use for the instance"
}

variable "security_groups" {
  type = list(string)
  description = "The security groups to use for the instance"
}

variable "region" {
  type = string
  description = "The region to use for the instance"
}