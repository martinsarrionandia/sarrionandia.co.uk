terraform {
  backend "s3" {
    bucket = "tf-state.sarrionandia.co.uk"
    key    = "backups/terraform.tfstate"
    region = "eu-west-2"
  }
} 