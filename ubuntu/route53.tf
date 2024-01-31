data "aws_route53_zone" "sarrionandia" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "sarrionandia_apex" {
  zone_id = data.aws_route53_zone.sarrionandia.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.sarrionandia.public_ip]
}