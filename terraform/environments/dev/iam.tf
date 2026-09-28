# IAM role that the Development EC2 instance can assume
resource "aws_iam_role" "dev_ec2_ssm_role" {
  name = "dev-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "dev-ec2-ssm-role"
  }
}

# Grants the role the required Systems Manager permissions
resource "aws_iam_role_policy_attachment" "dev_ssm_policy" {
  role       = aws_iam_role.dev_ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Makes the IAM role attachable to an EC2 instance
resource "aws_iam_instance_profile" "dev_ec2_profile" {
  name = "dev-ec2-ssm-instance-profile"
  role = aws_iam_role.dev_ec2_ssm_role.name

  tags = {
    Name = "dev-ec2-ssm-instance-profile"
  }
}