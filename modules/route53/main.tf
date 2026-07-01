# Route 53 Module for elderping.online
# The hosted zone is created and managed manually (outside Terraform) -
# this module only looks it up so other modules/resources can reference
# its zone_id and name servers.

data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}
