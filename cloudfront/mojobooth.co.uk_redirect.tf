data "aws_route53_zone" "mojobooth" {
  name         = "mojobooth.co.uk"
  private_zone = false
}

resource "aws_route53_record" "mojobooth_co_uk" {

  zone_id = data.aws_route53_zone.mojobooth.zone_id
  name    = "mojobooth.co.uk"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.mojobooth.domain_name
    zone_id                = aws_cloudfront_distribution.mojobooth.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "mojobooth_redirect" {
  bucket = "mojobooth-co-uk-redirect"

  tags = {
    Name    = "Mojobooth Redirect"
    Website = true
  }
}

resource "aws_s3_bucket_website_configuration" "mojobooth" {
  bucket = aws_s3_bucket.mojobooth_redirect.id

  redirect_all_requests_to {
    host_name = "www.djmaddox.co.uk/about/photo-mirror/"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_public_access_block" "mojobooth_redirect" {
  bucket = aws_s3_bucket.mojobooth_redirect.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_acm_certificate" "mojobooth" {
  provider          = aws.us-east-1
  domain_name       = "mojobooth.co.uk"
  validation_method = "DNS"
}

resource "aws_route53_record" "mojobooth_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mojobooth.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.mojobooth.zone_id
}

resource "aws_acm_certificate_validation" "mojobooth" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.mojobooth.arn
  validation_record_fqdns = [for record in aws_route53_record.mojobooth_acm_validation : record.fqdn]
}

data "aws_cloudfront_cache_policy" "mojobooth" {
  name = "Managed-CachingOptimized"
}



resource "aws_cloudfront_distribution" "mojobooth" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.mojobooth.website_endpoint
    origin_id   = aws_s3_bucket.mojobooth_redirect.bucket_regional_domain_name


    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }


  aliases = ["mojobooth.co.uk"]
  enabled = true

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.mojobooth.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.mojobooth_redirect.bucket_regional_domain_name

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
    acm_certificate_arn = aws_acm_certificate.mojobooth.id
    ssl_support_method  = "sni-only"
  }
}