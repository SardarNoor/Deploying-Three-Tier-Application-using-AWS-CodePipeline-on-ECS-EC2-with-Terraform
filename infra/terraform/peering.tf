resource "aws_vpc_peering_connection" "peer" {
  provider    = aws.west1
  vpc_id      = aws_vpc.west1.id
  peer_vpc_id = aws_vpc.west2.id
  peer_region = var.region_docdb
  auto_accept = false

  tags = merge(local.tags, { Name = "${local.name}-west1-to-west2" })
}

resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  provider                  = aws.west2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = merge(local.tags, { Name = "${local.name}-west2-accept" })
}

# Routes in WEST1 private RT -> WEST2 CIDR via peering
resource "aws_route" "west1_to_west2" {
  provider                  = aws.west1
  route_table_id            = aws_route_table.private_west1.id
  destination_cidr_block    = var.vpc_cidr_west2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  depends_on                = [aws_vpc_peering_connection_accepter.peer_accept]
}

# Routes in WEST2 private RT -> WEST1 CIDR via peering
resource "aws_route" "west2_to_west1" {
  provider                  = aws.west2
  route_table_id            = aws_route_table.private_west2.id
  destination_cidr_block    = var.vpc_cidr_west1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  depends_on                = [aws_vpc_peering_connection_accepter.peer_accept]
}
