# Systems Manager API endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.dev.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.dev_private.id
  ]

  security_group_ids = [
    aws_security_group.dev_endpoints.id
  ]

  tags = {
    Name = "dev-ssm-endpoint"
  }
}

# Session Manager secure messaging endpoint
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.dev.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.dev_private.id
  ]

  security_group_ids = [
    aws_security_group.dev_endpoints.id
  ]

  tags = {
    Name = "dev-ssmmessages-endpoint"
  }
}