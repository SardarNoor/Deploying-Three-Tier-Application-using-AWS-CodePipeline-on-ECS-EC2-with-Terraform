# ALB SG
resource "aws_security_group" "alb_sg" {
  provider = aws.west1
  name     = "${local.name}-alb-sg"
  vpc_id   = aws_vpc.west1.id

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_lb" "alb" {
  provider           = aws.west1
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public_west1 : s.id]
  tags               = local.tags
}

# Target groups
resource "aws_lb_target_group" "frontend_tg" {
  provider    = aws.west1
  name        = "${local.name}-frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.west1.id
  target_type = "ip"

  health_check {
    path = "/"
    matcher = "200-399"
  }

  tags = local.tags
}

resource "aws_lb_target_group" "backend_tg" {
  provider    = aws.west1
  name        = "${local.name}-backend-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.west1.id
  target_type = "ip"

  health_check {
    path = "/api"
    matcher = "200-399"
  }

  tags = local.tags
}

resource "aws_lb_listener" "http" {
  provider          = aws.west1
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# /api/* -> backend
resource "aws_lb_listener_rule" "api_rule" {
  provider     = aws.west1
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern { values = ["/api/*"] }
  }
}
