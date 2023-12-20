resource "aws_vpc" "fintech_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    {
      Name   = "fintech-vpc"
      Module = "vpc"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  for_each = toset(var.availability_zones)

  vpc_id     = aws_vpc.fintech_vpc.id
  cidr_block = var.public_subnet_cidrs[each.value]
  availability_zone = each.value
  map_public_ip_on_launch = true  # Enable auto-assign public IP

  tags = merge(
    var.common_tags,
    {
      Name   = "fintech-public-subnet-${each.value}"
      Module = "vpc"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fintech_vpc.id
  tags = merge(
    var.common_tags,
    {
      Name   = "fintech-igw"
      Module = "vpc"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.fintech_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.common_tags,
    {
      Name   = "fintech-public-route-table"
      Module = "vpc"
    }
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each      = aws_subnet.public_subnet
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}
