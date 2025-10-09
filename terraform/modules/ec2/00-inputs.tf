variable "ami" {
  type = string
  description = "The AMI to use for the instance"
}

variable "instance_type" {
  type = string
  description = "The instance type to use for the instance"
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

variable "vpc_security_group_ids" {
  type = list(string)
  description = "List of security group IDs to associate with."
}