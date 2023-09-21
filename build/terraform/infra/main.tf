terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    region = "us-east-1"
    key    = "aws-cert/infra/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      CreatorName = "grant.siders@slalom.com"
      CreatorId   = "AROA2NA6P72XD7HYAGIKV"
    }
  }
}
#Create VPC with private/public in 2azs
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = ">= 4.2.0"

  name       = "awslab-vpc"
  cidr_block = "10.100.0.0/20"
  az_count   = 2

  subnets = {
    public = {
      netmask                   = 24
      nat_gateway_configuration = "all_azs"
      tags = {
        subnet_type = "public"
      }
    }

    private = {
      netmask                 = 24
      connect_to_public_natgw = true
    }
  }
}
output "public_subnet_ids" {
  value = [for _, value in module.vpc.public_subnet_attributes_by_az : value.id]
}

output "private_subnet_ids" {
  value = [for _, value in module.vpc.private_subnet_attributes_by_az : value.id]
}

output "vpc_id" {
  value = module.vpc.vpc_attributes.id
}
#EC2 instance profile

resource "aws_iam_role" "ec2_role" {
  name               = "awslab-ec2-flask-app"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

output "ec2_role_id" {
  value = aws_iam_role.ec2_role.id
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}