terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    region = "us-east-1"
    key    = "awslab-cloud/iam/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      CreatorName = "grant.siders@slalom.com"
      CreatorId   = "AROA2NA6P72XD7HYAGIKV"
    }
  }
}
