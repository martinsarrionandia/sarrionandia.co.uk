provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Environment = "Legacy"
      Managedby   = "Terraform"
    }
  }
}