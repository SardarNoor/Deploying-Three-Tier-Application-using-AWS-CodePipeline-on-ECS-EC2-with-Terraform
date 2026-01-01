project_name = "muawin-cicd-ecs"
account_id   = "504649076991"

region_compute = "us-west-1"
region_docdb   = "us-west-2"

github_repo_full_name = "SardarNoor/Deploying-Three-Tier-Application-using-AWS-CodePipeline-on-ECS-EC2-with-Terraform"
github_branch         = "main"

# IMPORTANT: put your real CodeStar connection ARN here after you create it in AWS Console
codestar_connection_arn = "arn:aws:codeconnections:us-west-1:504649076991:connection/127f7db4-1799-4e3c-b338-f31d8cf9af30"


vpc_cidr_west1 = "10.10.0.0/16"
vpc_cidr_west2 = "10.20.0.0/16"

instance_type = "t3.medium"
asg_min       = 1
asg_desired   = 2
asg_max       = 4

backend_port  = 5000
frontend_port = 80

docdb_username = "muawinadmin"
docdb_password = "ChangeThisStrongPass123!"
docdb_dbname   = "muawin"
mongodb_uri = "mongodb://muawinadmin:ChangeThisStrongPass123!@muawin-cid-ecs-docdb.cluster-XXXX.us-west-2.docdb.amazonaws.com:27017/muawin?tls=true&tlsCAFile=/app/certs/global-bundle.pem&retryWrites=false"
