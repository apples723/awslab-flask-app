terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/flask-app/terraform.tfstate"
    region = "us-east-1"

  }
}
provider "aws" {
  region = "us-west-2"
}
