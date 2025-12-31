resource "aws_security_group" "docdb_sg" {
  provider = aws.west2
  name     = "${local.name}-docdb-sg"
  vpc_id   = aws_vpc.west2.id

  # allow from west1 VPC CIDR over peering
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_west1]
  }

 egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_docdb_subnet_group" "docdb_subnets" {
  provider   = aws.west2
  name       = "${local.name}-docdb-subnets"
  subnet_ids = [for s in aws_subnet.private_west2 : s.id]
  tags       = local.tags
}

resource "aws_docdb_cluster" "docdb" {
  provider                 = aws.west2
  cluster_identifier       = "${local.name}-docdb"
  master_username          = var.docdb_username
  master_password          = var.docdb_password
  db_subnet_group_name     = aws_docdb_subnet_group.docdb_subnets.name
  vpc_security_group_ids   = [aws_security_group.docdb_sg.id]
  skip_final_snapshot      = true
  deletion_protection      = false

  tags = local.tags
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  provider           = aws.west2
  identifier         = "${local.name}-docdb-1"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
  tags               = local.tags
}
