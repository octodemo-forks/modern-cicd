data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_subnet" "private_subnet" {
  count = 2

  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "public_route_assoc" {
  for_each = { for k,v in aws_subnet.public_subnet :
    k => v
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_assoc" {
  for_each = { for k,v in aws_subnet.private_subnet :
    k => v
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}