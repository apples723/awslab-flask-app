data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key = "awslab-cloud/vpc/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}

data "terraform_remote_state" "r53" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key = "awslab-cloud/r53/terraform.tfstate"
    region = "us-east-1"
  }
  workspace = terraform.workspace
}

#Home IP
data "http" "home_ip" {
  url = "https://homeip.gsiders.app"
}

#Current IP
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu
}
