output "id" {
  description = "The ID of the instance"
  value = aws_instance.this.id
}

output "arn" {
  description = "The ARN of the instance"
  value = aws_instance.this.arn
}

output "public_ip" {
  description = "The public IP of the instance"
  value = aws_instance.this.public_ip
}