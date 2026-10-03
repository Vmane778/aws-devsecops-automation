# Security group attached to the private EC2 instance
resource "aws_security_group" "dev_ec2" {
  name        = "dev-ec2-security-group"
  description = "Security group for the private Development EC2 instance"
  vpc_id      = aws_vpc.dev.id

  tags = {
    Name = "dev-ec2-security-group"
  }
}

# Security group attached to the Systems Manager interface endpoints
resource "aws_security_group" "dev_endpoints" {
  name        = "dev-endpoint-security-group"
  description = "Allows private HTTPS access from Development EC2"
  vpc_id      = aws_vpc.dev.id

  tags = {
    Name = "dev-endpoint-security-group"
  }
}

# EC2 can send HTTPS traffic only to resources using the endpoint SG
resource "aws_vpc_security_group_egress_rule" "dev_ec2_to_endpoints" {
  security_group_id            = aws_security_group.dev_ec2.id
  referenced_security_group_id = aws_security_group.dev_endpoints.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from EC2 to private AWS endpoints"
}

# Endpoints accept HTTPS only from resources using the EC2 SG
resource "aws_vpc_security_group_ingress_rule" "dev_endpoints_from_ec2" {
  security_group_id            = aws_security_group.dev_endpoints.id
  referenced_security_group_id = aws_security_group.dev_ec2.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from Development EC2"
}

