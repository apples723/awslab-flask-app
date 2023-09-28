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