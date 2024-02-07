provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Environment = "Legacy"
      Managedby   = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}