resource "aws_instance" "this" {
  ami                     = var.ami
  instance_type           = var.instance_type
  tags                    = var.tags
  subnet_id               = var.subnet_id
  security_groups         = var.security_groups
  user_data               = var.user_data
  availability_zone       = var.availability_zone
  region                  = var.region
}