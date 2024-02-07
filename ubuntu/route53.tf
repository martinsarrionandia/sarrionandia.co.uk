data "aws_route53_zone" "sarrionandia" {
  name         = "${var.domain_name}."
  private_zone = false
}

data "aws_route53_zone" "icons" {
  name         = "iconsfromjars.co.uk"
  private_zone = false
}

data "aws_route53_zone" "djmaddox" {
  name         = "djmaddox.co.uk"
  private_zone = false
}

resource "aws_route53_record" "sarrionandia_apex" {
  zone_id = data.aws_route53_zone.sarrionandia.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.sarrionandia.public_ip]
}

resource "aws_route53_record" "icons_www" {
  zone_id = data.aws_route53_zone.icons.zone_id
  name    = "www.iconsfromjars.co.uk"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.sarrionandia.public_ip]
}

resource "aws_route53_record" "djmaddox_www" {
  zone_id = data.aws_route53_zone.djmaddox.zone_id
  name    = "www.djmaddox.co.uk"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.sarrionandia.public_ip]
}
