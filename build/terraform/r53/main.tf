locals {
  flask_app_eips = length(data.terraform_remote_state.flask_app.outputs) > 0 ? data.terraform_remote_state.flask_app.outputs.flask_app_eips : []
  flask_app_weights = [1,3]
  az_letters = ["a","b","c","d"]
  env = split("-", terraform.workspace)[1]
  region_shorthand = split("-", terraform.workspace)[0]
}
#Create regional DNS zone ("usea1.slalom.awslab.cloud")
resource "aws_route53_zone" "regional_zone" {
  name = "${local.region_shorthand}.${var.top_level_domain}."
}

#Create the enviornment dns zone ("prod.usea1.slalom.awslab.cloud")
resource "aws_route53_zone" "env_zone" {
  name = "${local.env}.${local.region_shorthand}.${var.top_level_domain}."
}

output "env_zone_id" {
  value = aws_route53_zone.env_zone.zone_id
}

output "region_zone_id" {
  value = aws_route53_zone.regional_zone.zone_id
}

#NS records for each new zone
resource "aws_route53_record" "regional_ns_record" {
  count  = local.env == "dev" ? 1 : 0
  zone_id = data.aws_route53_zone.tld_zone.zone_id
  name    = aws_route53_zone.regional_zone.name
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.regional_zone.name_servers
}

resource "aws_route53_record" "env_ns_record" {
  zone_id = aws_route53_zone.regional_zone.zone_id
  name    = aws_route53_zone.env_zone.name
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.env_zone.name_servers
}

#Weighted flask app A records
resource "aws_route53_record" "flask_app" {
  count = length(local.flask_app_eips) > 0 ? length(local.flask_app_eips) : 0
  zone_id        = aws_route53_zone.env_zone.zone_id
  name           = "app1.${aws_route53_zone.env_zone.name}"
  type           = "A"
  ttl            = "300"
  
  weighted_routing_policy {
    weight    = local.flask_app_weights[count.index]
  }

  set_identifier = "instance-${count.index + 1}"
  records        = [local.flask_app_eips[count.index]]
}

#record for each flask app server
resource "aws_route53_record" "ec_flask_app" {
  count = length(local.flask_app_eips) > 0 ? length(local.flask_app_eips) : 0
  zone_id        = aws_route53_zone.env_zone.zone_id
  name           = "app1-${local.az_letters[count.index]}.${aws_route53_zone.env_zone.name}"
  type           = "A"
  ttl            = "300"

  records        = [local.flask_app_eips[count.index]]
}