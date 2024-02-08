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

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}