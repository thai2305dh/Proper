resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.name}-internet-gateway"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  for_each = var.map_az_subnet
  availability_zone = each.key
  cidr_block = each.value
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.name}-${each.value}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_association" {
  depends_on = [aws_subnet.public_subnet]
  route_table_id = aws_route_table.public_route_table.id
  for_each = aws_subnet.public_subnet
  subnet_id = each.value.id
}
