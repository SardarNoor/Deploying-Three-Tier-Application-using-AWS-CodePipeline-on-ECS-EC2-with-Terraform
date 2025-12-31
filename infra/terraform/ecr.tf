resource "aws_ecr_repository" "backend" {
  provider = aws.west1
  name     = "backend-repo"
  tags     = local.tags
}

resource "aws_ecr_repository" "frontend" {
  provider = aws.west1
  name     = "frontend-repo"
  tags     = local.tags
}
