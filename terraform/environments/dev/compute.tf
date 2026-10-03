# Find the newest Amazon Linux 2023 x86-64 AMI in the selected region
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Private Development EC2 instance
resource "aws_instance" "dev_private" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.dev_private.id

  vpc_security_group_ids = [
    aws_security_group.dev_ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.dev_ec2_profile.name

  associate_public_ip_address = false

  # Require secure Instance Metadata Service v2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt the root storage volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "dev-private-ec2"
  }

  # Wait for SSM permissions and private endpoints
  depends_on = [
    aws_iam_role_policy_attachment.dev_ssm_policy,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.ssmmessages
  ]
}