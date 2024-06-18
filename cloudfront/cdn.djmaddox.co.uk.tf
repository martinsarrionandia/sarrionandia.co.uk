resource "aws_route53_record" "cdn_djmaddox_co_uk" {

  zone_id = data.aws_route53_zone.djmaddox_co_uk.zone_id
  name    = "cdn.djmaddox.co.uk"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn_djmaddox_co_uk.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_djmaddox_co_uk.hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_s3_bucket" "cdn_djmaddox_co_uk" {
  provider = aws.eu-west-1
  bucket   = "cdn.djmaddox.co.uk"
}

data "aws_iam_policy_document" "cdn_djmaddox_co_uk" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.cdn_djmaddox_co_uk.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn_djmaddox_co_uk.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_djmaddox_co_uk" {
  provider = aws.eu-west-1
  bucket   = data.aws_s3_bucket.cdn_djmaddox_co_uk.id
  policy   = data.aws_iam_policy_document.cdn_djmaddox_co_uk.json
}

resource "aws_s3_bucket_public_access_block" "cdn_djmaddox_co_uk" {
  provider = aws.eu-west-1
  bucket   = data.aws_s3_bucket.cdn_djmaddox_co_uk.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "cdn_djmaddox_co_uk" {
  provider          = aws.us-east-1
  domain_name       = "cdn.djmaddox.co.uk"
  validation_method = "DNS"
}

resource "aws_route53_record" "cdn_djmaddox_co_uk_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn_djmaddox_co_uk.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "cdn_djmaddox_co_uk" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cdn_djmaddox_co_uk.arn
  validation_record_fqdns = [for record in aws_route53_record.cdn_djmaddox_co_uk_acm_validation : record.fqdn]
}

data "aws_cloudfront_cache_policy" "cdn_djmaddox_co_uk" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "cdn_djmaddox_co_uk" {
  name                              = "cdn.djmaddox.co.uk"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "cache-control" {
  name = "Cache-Control"

  custom_headers_config {

    items {
      header   = "Cache-Control"
      override = true
      #value    = "max-age=2628000"
      value = "max-age=31536000"
    }
  }
}

resource "aws_cloudfront_distribution" "cdn_djmaddox_co_uk" {
  origin {
    domain_name              = data.aws_s3_bucket.cdn_djmaddox_co_uk.bucket_regional_domain_name
    origin_id                = data.aws_s3_bucket.cdn_djmaddox_co_uk.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn_djmaddox_co_uk.id
  }


  aliases = ["cdn.djmaddox.co.uk"]
  enabled = true

  default_cache_behavior {
    cache_policy_id            = data.aws_cloudfront_cache_policy.cdn_djmaddox_co_uk.id
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = data.aws_s3_bucket.cdn_djmaddox_co_uk.bucket_regional_domain_name
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cache-control.id
    viewer_protocol_policy     = "allow-all"
    min_ttl                    = 0
    default_ttl                = 3600
    max_ttl                    = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cdn_djmaddox_co_uk.id
    ssl_support_method  = "sni-only"
  }
}