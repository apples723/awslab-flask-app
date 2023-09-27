#Config

terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    key    = "aws-cert/r53/terraform.tfstate"
    region = "us-east-1"

  }
}

provider "aws" {
  region = "us-west-2"
}


#Variables

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


#Local values

locals {
  flask_app_eips = data.terraform_remote_state.flask_app.outputs.flask_app_eips
  flask_app_weights = [1,3]
}


#Data Sources

data "terraform_remote_state" "flask_app" {
  backend = "s3"
  config  = {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/flask-app/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}
data "aws_route53_zone" "tld_zone" {
  name = var.top_level_domain
}

#Create regional DNS zone ("usea1.slalom.awslab.cloud")
resource "aws_route53_zone" "regional_zone" {
  name = "${var.region_shorthand}.${var.top_level_domain}."
}

#Create the enviornment dns zone ("prod.usea1.slalom.awslab.cloud")
resource "aws_route53_zone" "env_zone" {
  name = "${var.environment}.${var.region_shorthand}.${var.top_level_domain}."
}

#NS records for each new zone
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

#Weighted flask app A records
resource "aws_route53_record" "flask_app" {
  count = length(local.flask_app_eips)
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