terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    key    = "aws-cert/flask-app/terraform.tfstate"
    region = "us-east-1"

  }
}
provider "aws" {
  region = "us-west-2"
}
