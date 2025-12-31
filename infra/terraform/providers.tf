provider "aws" {
  alias  = "west1"
  region = var.region_compute
}

provider "aws" {
  alias  = "west2"
  region = var.region_docdb
}
