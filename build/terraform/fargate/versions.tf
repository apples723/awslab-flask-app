terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    region = "us-east-1"
    key    = "awslab-cloud/fargate/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      CreatorName = "grant.siders@slalom.com"
      CreatorId   = "AROA2NA6P72XD7HYAGIKV"
    }
  }
}
