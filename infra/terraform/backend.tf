terraform {
  backend "s3" {
    bucket         = "noor-terraformstate"
    key            = "task8/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
  }
}
