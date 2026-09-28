variable "dev_vpc_cidr" {
  description = "CIDR block for the development VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "dev_private_subnet_cidr" {
  description = "CIDR block for the development private subnet"
  type        = string
  default     = "10.20.0.0/24"
}

variable "aws_region" {
  description = "AWS region for the development environment"
  type        = string
  default     = "us-east-2"
}