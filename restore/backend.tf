terraform {
  backend "s3" {
    bucket = "sarrionandia.co.uk"
    key    = "terraform-state/sarrionandia.co.uk/restore/terraform.tfstate"
    region = "eu-west-1"
  }
}