terraform {
  backend "s3" {
    bucket = "sarrionandia.co.uk"
    key    = "terraform-state/sarrionandia.co.uk/backups/terraform.tfstate"
    region = "eu-west-1"
  }
}