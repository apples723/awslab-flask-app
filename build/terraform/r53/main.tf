variable "top_level_domain" {
  description = "The top-level domain name."
  default     = "slalom.awslab.cloud"
}

variable "region_shorthand" {
  description = "The shorthand for the AWS region."
}

variable "environment" {
  description = "The environment (e.g., dev, stg, prod)."
}

data "aws_route53_zone" "tld_zone" {
  name = var.top_level_domain
}

resource "aws_route53_zone" "regional_zone" {
  name = "${var.region_shorthand}.${var.top_level_domain}."
}

resource "aws_route53_zone" "env_zone" {
  name = "${var.environment}.${var.region_shorthand}.${var.top_level_domain}."
}

resource "aws_route53_record" "regional_ns_record" {
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

resource "aws_route53_record" "web_app" {
  zone_id = aws_route53_zone.env_zone.zone_id
  name    = "app1.${aws_route53_zone.env_zone.name}"
  type    = "A"
  ttl     = "300"
  weight  = 10  # Set the weight for each record
  set_identifier = "instance-${count.index + 1}"
  records = ["<EC2_INSTANCE_IP>"]  # Replace with the actual IP of the EC2 instance
}