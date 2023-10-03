locals {
  region_short_hand = {
    "us-west-2" = "uswe2"
    "us-east-1" = "usea1"
    "ap-southeast-1" = "apse1"
  }
  flask_app_alb_fqdn       = "flask.${local.flask_app_alb_sub_domain}"
  flask_app_alb_sub_domain = "${var.env}.${local.region_short_hand[var.aws_region]}.${var.sub_domain_name}"
  flask_app_alb_latency_fqdn = "flask-${var.env}.${local.lab_tld}"
  lab_tld = "slalom.awslab.cloud"
}


data "aws_route53_zone" "sub_domain_zone" {
  name = local.flask_app_alb_sub_domain
}

data "aws_route53_zone" "tld_zone" {
  name = local.lab_tld
}

resource "aws_acm_certificate" "flask_app_alb" {
  domain_name       = local.flask_app_alb_fqdn
  validation_method = "DNS"
}


resource "aws_route53_record" "flask_app_alb_validation" {
  for_each = {
    for dvo in aws_acm_certificate.flask_app_alb.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.sub_domain_zone.id
}

resource "aws_acm_certificate_validation" "flask_app_alb" {
  certificate_arn         = aws_acm_certificate.flask_app_alb.arn
  validation_record_fqdns = [for record in aws_route53_record.flask_app_alb_validation : record.fqdn]
}


resource "aws_route53_record" "flask_alb" {
  name    = "flask"
  type    = "A"
  zone_id = data.aws_route53_zone.sub_domain_zone.id
  alias {
    name                   = aws_alb.flask_app.dns_name
    zone_id                = aws_alb.flask_app.zone_id
    evaluate_target_health = false
  }
}

#Latency Record

resource "aws_route53_record" "flask_latency" {
  set_identifier = "${data.aws_region.current.name}-${var.env}"
  name = "flask-${var.env}"
  type = "A"
  zone_id = data.aws_route53_zone.tld_zone.zone_id
  latency_routing_policy {
    region = data.aws_region.current.name
  }
  alias {
    name = aws_alb.flask_app.dns_name
    zone_id = aws_alb.flask_app.zone_id
    evaluate_target_health = false
  }

  depends_on = [ aws_acm_certificate.flask_app_latency ]
}


resource "aws_acm_certificate" "flask_app_latency" {
  domain_name       = local.flask_app_alb_latency_fqdn
  validation_method = "DNS"
}


resource "aws_route53_record" "flask_app_latency_validation" {
  for_each = {
    for dvo in aws_acm_certificate.flask_app_latency.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.tld_zone.zone_id
}

resource "aws_acm_certificate_validation" "flask_app_latency" {
  certificate_arn         = aws_acm_certificate.flask_app_latency.arn
  validation_record_fqdns = [for record in aws_route53_record.flask_app_latency_validation : record.fqdn]
}
