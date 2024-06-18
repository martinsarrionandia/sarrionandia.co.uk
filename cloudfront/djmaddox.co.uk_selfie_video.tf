resource "aws_route53_record" "djmaddox-co-uk-photomirror" {

  zone_id = data.aws_route53_zone.djmaddox_co_uk.zone_id
  name    = local.photomirror_fqdn
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.djmaddox-co-uk-photomirror.domain_name
    zone_id                = aws_cloudfront_distribution.djmaddox-co-uk-photomirror.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "djmaddox-co-uk-photomirror" {
  bucket = "djmaddox-co-uk-photomirror"

  tags = {
    Name    = "Photo Mirror Promo Video"
    Website = true
  }
}

resource "aws_s3_object" "index_file" {
  bucket  = aws_s3_bucket.djmaddox-co-uk-photomirror.id
  key     = local.photomirror_index_file
  content = templatefile("${path.module}/templates/${local.photomirror_index_file}", { fqdn = local.photomirror_fqdn })

}

resource "aws_s3_bucket_website_configuration" "djmaddox-co-uk-photomirror" {
  bucket = aws_s3_bucket.djmaddox-co-uk-photomirror.id

  index_document {
    suffix = local.photomirror_index_file
  }

}

resource "aws_s3_bucket_public_access_block" "djmaddox-co-uk-photomirror" {
  bucket = aws_s3_bucket.djmaddox-co-uk-photomirror.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_acm_certificate" "djmaddox-co-uk-photomirror" {
  provider          = aws.us-east-1
  domain_name       = local.photomirror_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "djmaddox-co-uk-photomirror-acm-validation" {
  for_each = {
    for dvo in aws_acm_certificate.djmaddox-co-uk-photomirror.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "djmaddox-co-uk-photomirror" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.djmaddox-co-uk-photomirror.arn
  validation_record_fqdns = [for record in aws_route53_record.djmaddox-co-uk-photomirror-acm-validation : record.fqdn]
}

data "aws_cloudfront_cache_policy" "djmaddox-co-uk-photomirror" {
  name = "Managed-CachingDisabled"
}



resource "aws_cloudfront_distribution" "djmaddox-co-uk-photomirror" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.djmaddox-co-uk-photomirror.website_endpoint
    origin_id   = aws_s3_bucket.djmaddox-co-uk-photomirror.bucket_regional_domain_name


    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }


  aliases = ["${local.photomirror_fqdn}"]
  enabled = true

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.djmaddox-co-uk-photomirror.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.djmaddox-co-uk-photomirror.bucket_regional_domain_name

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
    acm_certificate_arn = aws_acm_certificate.djmaddox-co-uk-photomirror.id
    ssl_support_method  = "sni-only"
  }
}

locals {
  photomirror_fqdn       = "photo-mirror-promo-video.djmaddox.co.uk"
  photomirror_index_file = "video_og_meta.html"
}