resource "aws_instance" "this" {
  ami                     = var.ami
  instance_type           = var.instance_type
  tags                    = var.tags
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = var.vpc_security_group_ids
  user_data               = var.user_data
}