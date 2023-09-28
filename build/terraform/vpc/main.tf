terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    region = "us-east-1"
    key    = "awslab-cloud/vpc/terraform.tfstate"
  }
}
variable "vpc_cidr" {
  default = ""
}

variable "vpc_name" {
  default = "awslab-vpc"
}
variable "region" {}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      CreatorName = "grant.siders@slalom.com"
      CreatorId   = "AROA2NA6P72XD7HYAGIKV"
    }
  }
}

#Create VPC with private/public in 2azs
module "vpc" {
  source = "git@github.com:aws-ia/terraform-aws-vpc"
  name       = var.vpc_name
  cidr_block = var.vpc_cidr
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
