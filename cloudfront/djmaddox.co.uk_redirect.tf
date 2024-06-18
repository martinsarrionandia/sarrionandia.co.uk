resource "aws_route53_record" "djmaddox_co_uk_apex" {

  zone_id = data.aws_route53_zone.djmaddox_co_uk.zone_id
  name    = "djmaddox.co.uk"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.djmaddox_co_uk.domain_name
    zone_id                = aws_cloudfront_distribution.djmaddox_co_uk.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "djmaddox_co_uk_redirect" {
  bucket = "djmaddox.co.uk-redirect"

  tags = {
    Name    = "djmaddox_co_uk Redirect"
    Website = true
  }
}

resource "aws_s3_bucket_website_configuration" "djmaddox_co_uk" {
  bucket = aws_s3_bucket.djmaddox_co_uk_redirect.id

  redirect_all_requests_to {
    host_name = "www.djmaddox.co.uk"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_public_access_block" "djmaddox_co_uk_redirect" {
  bucket = aws_s3_bucket.djmaddox_co_uk_redirect.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_acm_certificate" "djmaddox_co_uk" {
  provider          = aws.us-east-1
  domain_name       = "djmaddox.co.uk"
  validation_method = "DNS"
}

resource "aws_route53_record" "djmaddox_co_uk_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.djmaddox_co_uk.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.djmaddox_co_uk.zone_id
}

resource "aws_acm_certificate_validation" "djmaddox_co_uk" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.djmaddox_co_uk.arn
  validation_record_fqdns = [for record in aws_route53_record.djmaddox_co_uk_acm_validation : record.fqdn]
}

data "aws_cloudfront_cache_policy" "djmaddox_co_uk" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "djmaddox_co_uk" {
  name                              = "djmaddox.co.uk"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "djmaddox_co_uk" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.djmaddox_co_uk.website_endpoint
    origin_id   = aws_s3_bucket.djmaddox_co_uk_redirect.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["djmaddox.co.uk"]
  enabled = true

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.djmaddox_co_uk.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.djmaddox_co_uk_redirect.bucket_regional_domain_name

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.djmaddox_co_uk.id
    ssl_support_method  = "sni-only"
  }
}

locals {
  djmaddox_fqdn       = "djmaddox.co.uk"
}