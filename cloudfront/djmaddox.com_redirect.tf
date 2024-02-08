data "aws_route53_zone" "djmaddox_com" {
  name         = "djmaddox.com"
  private_zone = false
}

resource "aws_route53_record" "djmaddox_com_apex" {

  zone_id = data.aws_route53_zone.djmaddox_com.zone_id
  name    = "djmaddox.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.djmaddox_com.domain_name
    zone_id                = aws_cloudfront_distribution.djmaddox_com.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "djmaddox_com_redirect" {
  bucket = "djmaddox.com-redirect"

  tags = {
    Name    = "djmaddox_com Redirect"
    Website = true
  }
}

resource "aws_s3_bucket_website_configuration" "djmaddox_com" {
  bucket = aws_s3_bucket.djmaddox_com_redirect.id

  redirect_all_requests_to {
    host_name = "www.djmaddox.co.uk"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_public_access_block" "djmaddox_redirect" {
  bucket = aws_s3_bucket.djmaddox_com_redirect.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_acm_certificate" "djmaddox_com" {
  provider          = aws.us-east-1
  domain_name       = "djmaddox.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "djmaddox_com_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.djmaddox_com.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.djmaddox_com.zone_id
}

resource "aws_acm_certificate_validation" "djmaddox_com" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.djmaddox_com.arn
  validation_record_fqdns = [for record in aws_route53_record.djmaddox_com_acm_validation : record.fqdn]
}

data "aws_cloudfront_cache_policy" "djmaddox_com" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "djmaddox_com" {
  name                              = "djmaddox.com"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "djmaddox_com" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.djmaddox_com.website_endpoint
    origin_id   = aws_s3_bucket.djmaddox_com_redirect.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["djmaddox.com"]
  enabled = true

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.djmaddox_com.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.djmaddox_com_redirect.bucket_regional_domain_name

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
    acm_certificate_arn = aws_acm_certificate.djmaddox_com.id
    ssl_support_method  = "sni-only"
  }
}