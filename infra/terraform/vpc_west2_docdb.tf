data "aws_availability_zones" "west2" {
  provider = aws.west2
  state    = "available"
}

resource "aws_vpc" "west2" {
  provider             = aws.west2
  cidr_block           = var.vpc_cidr_west2
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "${local.name}-vpc-west2-docdb" })
}

# Private subnets only (2 AZ)
resource "aws_subnet" "private_west2" {
  provider          = aws.west2
  count             = 2
  vpc_id            = aws_vpc.west2.id
  cidr_block        = cidrsubnet(var.vpc_cidr_west2, 8, 100 + count.index)
  availability_zone = data.aws_availability_zones.west2.names[count.index]
  tags = merge(local.tags, { Name = "${local.name}-docdb-private-${count.index}" })
}

resource "aws_route_table" "private_west2" {
  provider = aws.west2
  vpc_id   = aws_vpc.west2.id
  tags = merge(local.tags, { Name = "${local.name}-rt-docdb-private" })
}

resource "aws_route_table_association" "private_west2_assoc" {
  provider       = aws.west2
  count          = 2
  subnet_id      = aws_subnet.private_west2[count.index].id
  route_table_id = aws_route_table.private_west2.id
}
