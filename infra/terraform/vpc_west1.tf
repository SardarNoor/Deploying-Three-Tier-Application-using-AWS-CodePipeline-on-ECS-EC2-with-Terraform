data "aws_availability_zones" "west1" {
  provider = aws.west1
  state    = "available"
}

resource "aws_vpc" "west1" {
  provider             = aws.west1
  cidr_block           = var.vpc_cidr_west1
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "${local.name}-vpc-west1" })
}

resource "aws_internet_gateway" "west1" {
  provider = aws.west1
  vpc_id   = aws_vpc.west1.id
  tags = merge(local.tags, { Name = "${local.name}-igw" })
}

# Public subnets (2 AZ)
resource "aws_subnet" "public_west1" {
  provider                = aws.west1
  count                   = 2
  vpc_id                  = aws_vpc.west1.id
  cidr_block              = cidrsubnet(var.vpc_cidr_west1, 8, count.index)
  availability_zone       = data.aws_availability_zones.west1.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "${local.name}-public-${count.index}" })
}

# Private subnets (2 AZ)
resource "aws_subnet" "private_west1" {
  provider          = aws.west1
  count             = 2
  vpc_id            = aws_vpc.west1.id
  cidr_block        = cidrsubnet(var.vpc_cidr_west1, 8, 100 + count.index)
  availability_zone = data.aws_availability_zones.west1.names[count.index]
  tags = merge(local.tags, { Name = "${local.name}-private-${count.index}" })
}

# Public route table
resource "aws_route_table" "public_west1" {
  provider = aws.west1
  vpc_id   = aws_vpc.west1.id
  tags = merge(local.tags, { Name = "${local.name}-rt-public" })
}

resource "aws_route" "public_internet" {
  provider               = aws.west1
  route_table_id         = aws_route_table.public_west1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.west1.id
}

resource "aws_route_table_association" "public_assoc" {
  provider       = aws.west1
  count          = 2
  subnet_id      = aws_subnet.public_west1[count.index].id
  route_table_id = aws_route_table.public_west1.id
}

# NAT for private subnets
resource "aws_eip" "nat_eip" {
  provider = aws.west1
  domain   = "vpc"
  tags = merge(local.tags, { Name = "${local.name}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  provider      = aws.west1
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_west1[0].id
  depends_on    = [aws_internet_gateway.west1]
  tags = merge(local.tags, { Name = "${local.name}-nat" })
}

resource "aws_route_table" "private_west1" {
  provider = aws.west1
  vpc_id   = aws_vpc.west1.id
  tags = merge(local.tags, { Name = "${local.name}-rt-private" })
}

resource "aws_route" "private_nat" {
  provider               = aws.west1
  route_table_id         = aws_route_table.private_west1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  provider       = aws.west1
  count          = 2
  subnet_id      = aws_subnet.private_west1[count.index].id
  route_table_id = aws_route_table.private_west1.id
}
