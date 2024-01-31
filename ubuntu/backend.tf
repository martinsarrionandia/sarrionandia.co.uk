terraform {
  backend "s3" {
    bucket = "sarrionandia.co.uk"
    key    = "terraform-state/sarrionandia.co.uk/ubuntu/terraform.tfstate"
    region = "eu-west-1"
  }
}