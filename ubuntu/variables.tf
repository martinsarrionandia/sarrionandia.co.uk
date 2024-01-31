variable "availability_zone" {
  type        = string
  default     = "eu-west-2a"
  description = "The AZ you want to deploy the infrastructure. Only ONE AZ is created"
}

variable "legacy_admin_https" {
  type        = string
  default     = "10000"
  description = "This defines a HTTPS managment port for Webmin"
}

variable "instance_key_name" {
  type    = string
  default = "sarrionandia-eu-w2"
}

variable "domain_name" {
  type    = string
  default = "sarrionandia.co.uk"
}