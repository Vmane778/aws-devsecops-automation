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

output "ssm_vpc_endpoint_id" {
  description = "ID of the SSM interface endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssmmessages_vpc_endpoint_id" {
  description = "ID of the Session Manager interface endpoint"
  value       = aws_vpc_endpoint.ssmmessages.id
}

output "dev_endpoints_sg_id" {
  description = "Security group ID attached to the endpoints"
  value       = aws_security_group.dev_endpoints.id
}

output "dev_ec2_sg_id" {
  description = "Security group ID attached to the EC2 instance"
  value       = aws_security_group.dev_ec2.id
}

output "dev_iam_role_arn" {
  description = "ARN of the EC2 IAM role for SSM"
  value       = aws_iam_role.dev_ec2_ssm_role.arn
}

output "dev_s3_bucket_name" {
  description = "Name of the private Development S3 bucket"
  value       = aws_s3_bucket.dev_app_files.bucket
}