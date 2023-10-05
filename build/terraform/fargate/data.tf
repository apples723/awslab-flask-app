data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/vpc/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}

data "terraform_remote_state" "flask_app" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/flask-app/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}


data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/bastion/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key    = "awslab-cloud/iam/terraform.tfstate"
    region = "us-east-1"
  }

}


#Home IP
data "http" "home_ip" {
  url = "https://homeip.gsiders.app"
}

#Current IP
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}
