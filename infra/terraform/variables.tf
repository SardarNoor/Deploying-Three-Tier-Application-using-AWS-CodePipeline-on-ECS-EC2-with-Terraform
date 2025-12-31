variable "project_name" { type = string }
variable "account_id"   { type = string }

variable "region_compute" { type = string } # us-west-1
variable "region_docdb"   { type = string } # us-west-2

# GitHub via CodeStar Connection (create once in AWS Console, then paste ARN here)
variable "codestar_connection_arn" { type = string }
variable "github_repo_full_name"   { type = string } # e.g. SardarNoor/Deploying-Three-Tier-Application-using-AWS-CodePipeline-on-ECS-EC2-with-Terraform
variable "github_branch"           { type = string } # main

# Networking
variable "vpc_cidr_west1" { type = string }
variable "vpc_cidr_west2" { type = string }

# ECS capacity
variable "instance_type" { type = string } # t3.medium
variable "asg_min"       { type = number } # 1
variable "asg_desired"   { type = number } # 2
variable "asg_max"       { type = number } # 4

# App ports
variable "backend_port"  { type = number } # 5000
variable "frontend_port" { type = number } # 80

# DocumentDB
variable "docdb_username" { type = string }
variable "docdb_password" { type = string } # keep in tfvars for now (later move to SSM)
variable "docdb_dbname"   { type = string } # muawin
