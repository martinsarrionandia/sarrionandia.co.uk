data "aws_route53_zone" "djmaddox_co_uk" {
  name         = "djmaddox.co.uk"
  private_zone = false
}

data "aws_route53_zone" "djmaddox_com" {
  name         = "djmaddox.com"
  private_zone = false
}

data "aws_route53_zone" "mojobooth" {
  name         = "mojobooth.co.uk"
  private_zone = false
}