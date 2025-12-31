terraform {
  backend "s3" {
    bucket         = "noor-terraformstate"
    key            = "task8/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
