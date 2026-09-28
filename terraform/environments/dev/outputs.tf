output "dev_vpc_id" {
  description = "ID of the Development VPC"
  value       = aws_vpc.dev.id
}

output "dev_private_subnet_id" {
  description = "ID of the Development private subnet"
  value       = aws_subnet.dev_private.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 gateway endpoint"
  value       = aws_vpc_endpoint.s3.id
}