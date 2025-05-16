terraform {
  backend "s3" {
    bucket  = "sarrionandia.co.uk"
    key     = "terraform-state/linkedin/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}