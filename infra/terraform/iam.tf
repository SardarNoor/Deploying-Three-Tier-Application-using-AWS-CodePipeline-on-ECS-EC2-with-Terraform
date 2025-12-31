# ECS EC2 instance role
data "aws_iam_policy_document" "ecs_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs_instance_role" {
  provider           = aws.west1
  name               = "${local.name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_instance_attach" {
  provider   = aws.west1
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  provider = aws.west1
  name     = "${local.name}-ecs-instance-profile"
  role     = aws_iam_role.ecs_instance_role.name
}

# ECS task execution role (pull from ECR, write logs)
data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs_task_execution" {
  provider           = aws.west1
  name               = "${local.name}-ecs-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  provider   = aws.west1
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CodeBuild role
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "codebuild_role" {
  provider           = aws.west1
  name               = "${local.name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "codebuild_inline" {
  provider = aws.west1
  name     = "${local.name}-codebuild-inline"
  role     = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect="Allow", Action=[
          "ecr:GetAuthorizationToken","ecr:BatchCheckLayerAvailability","ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart","ecr:InitiateLayerUpload","ecr:PutImage","ecr:BatchGetImage"
        ], Resource="*"
      },
      { Effect="Allow", Action=["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource="*" },
      { Effect="Allow", Action=["s3:GetObject","s3:PutObject","s3:GetObjectVersion","s3:GetBucketVersioning"], Resource="*" }
    ]
  })
}

# CodePipeline role
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "codepipeline_role" {
  provider           = aws.west1
  name               = "${local.name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "codepipeline_inline" {
  provider = aws.west1
  name     = "${local.name}-codepipeline-inline"
  role     = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      { Effect="Allow", Action=["s3:*"], Resource="*" },
      { Effect="Allow", Action=["codebuild:BatchGetBuilds","codebuild:StartBuild"], Resource="*" },
      { Effect="Allow", Action=["ecs:*","iam:PassRole"], Resource="*" },
  {
  Effect = "Allow",
  Action = [
    "codestar-connections:UseConnection",
    "codeconnections:UseConnection"
  ],
  Resource = var.codestar_connection_arn
}


    ]
  })
}
