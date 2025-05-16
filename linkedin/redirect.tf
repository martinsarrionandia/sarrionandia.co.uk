
module "linkedin-302" {
  source     = "github.com/martinsarrionandia/tfmod-cloudfront-302.git"
  domain     = "sarrionandia.co.uk"
  hostname   = "linkedin"
  target_url = "www.linkedin.com/in/martin-sarrionandia"
}