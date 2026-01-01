resource "aws_ecs_cluster" "cluster" {
  provider = aws.west1
  name     = "${local.name}-cluster"
  tags     = local.tags
}

# ECS Optimized AMI (AL2)
data "aws_ssm_parameter" "ecs_ami" {
  provider = aws.west1
  name     = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Security group for ECS tasks (allow from ALB)
resource "aws_security_group" "ecs_tasks_sg" {
  provider = aws.west1
  name     = "${local.name}-ecs-tasks-sg"
  vpc_id   = aws_vpc.west1.id

  ingress {
    from_port       = var.frontend_port
    to_port         = var.frontend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

 egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

# SG for EC2 instances
resource "aws_security_group" "ecs_instances_sg" {
  provider = aws.west1
  name     = "${local.name}-ecs-instances-sg"
  vpc_id   = aws_vpc.west1.id

  ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.vpc_cidr_west1]
}

egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

  tags = local.tags
}

resource "aws_launch_template" "ecs_lt" {
  provider      = aws.west1
  name_prefix   = "${local.name}-ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  iam_instance_profile { name = aws_iam_instance_profile.ecs_instance_profile.name }
  vpc_security_group_ids = [aws_security_group.ecs_instances_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  provider            = aws.west1
  name                = "${local.name}-ecs-asg"
  min_size            = var.asg_min
  desired_capacity    = var.asg_desired
  max_size            = var.asg_max
  vpc_zone_identifier = [for s in aws_subnet.private_west1 : s.id]

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-ecs-node"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "cp" {
  provider = aws.west1
  name     = "${local.name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 4
    }
  }

  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "attach" {
  provider = aws.west1
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [aws_ecs_capacity_provider.cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
    base              = 1
  }
}

# CloudWatch log groups
resource "aws_cloudwatch_log_group" "backend_lg" {
  provider = aws.west1
  name     = "/ecs/${local.name}/backend"
  retention_in_days = 14
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "frontend_lg" {
  provider = aws.west1
  name     = "/ecs/${local.name}/frontend"
  retention_in_days = 14
  tags = local.tags
}

# Task definitions (image gets updated by CodePipeline deploy via imagedefinitions)
resource "aws_ecs_task_definition" "backend_td" {
  provider                 = aws.west1
  family                   = "${local.name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${var.account_id}.dkr.ecr.${var.region_compute}.amazonaws.com/backend-repo:latest"
      essential = true
      portMappings = [{ containerPort = var.backend_port, protocol = "tcp" }]

     environment = [
  { name = "PORT",       value = tostring(var.backend_port) },
  { name = "NODE_ENV",   value = "production" },

  # app reads this
  { name = "MONGODB_URI", value = var.mongodb_uri },

  
  { name = "DOCDB_USER", value = var.docdb_username },
  { name = "DOCDB_PASS", value = var.docdb_password }
]


      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend_lg.name,
          awslogs-region        = var.region_compute,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "frontend_td" {
  provider                 = aws.west1
  family                   = "${local.name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "${var.account_id}.dkr.ecr.${var.region_compute}.amazonaws.com/frontend-repo:latest"
      essential = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend_lg.name,
          awslogs-region        = var.region_compute,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ECS services
resource "aws_ecs_service" "backend_svc" {
  provider        = aws.west1
  name            = "${local.name}-backend-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend_td.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [for s in aws_subnet.private_west1 : s.id]
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = "backend"
    container_port   = var.backend_port
  }

  depends_on = [aws_lb_listener_rule.api_rule]
}

resource "aws_ecs_service" "frontend_svc" {
  provider        = aws.west1
  name            = "${local.name}-frontend-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend_td.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [for s in aws_subnet.private_west1 : s.id]
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}
