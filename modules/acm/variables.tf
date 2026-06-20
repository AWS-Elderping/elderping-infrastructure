variable "domain_name" {
  type        = string
  description = "The primary domain name for the certificate"
}

variable "route53_zone_id" {
  type        = string
  description = "The Route 53 zone ID for creating validation records"
}
