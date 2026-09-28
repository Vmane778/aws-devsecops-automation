resource "aws_vpc" "dev" {
  cidr_block           = var.dev_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dev_private" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.dev_private_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false


  tags = {
    Name = "dev-private-subnet"
  }
}

resource "aws_route_table" "dev_private" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-private-route-table"
  }
}

resource "aws_route_table_association" "dev_private" {
  subnet_id      = aws_subnet.dev_private.id
  route_table_id = aws_route_table.dev_private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.dev.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.dev_private.id]

  tags = {
    Name = "dev-s3-vpc-endpoint"
  }

}