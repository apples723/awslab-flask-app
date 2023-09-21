terraform {
    backend "s3" {
        bucket = "gsiders-tf"
        region = "us-east-1"
        key = "aws-cert/infra/terraform.tfstate"
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


#DynamoDB 
resource "aws_dynamodb_table" "example" {
  name         = "flask-app-status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "example-table"
  }
}


resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "awslab-flask-app-ddb"

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

data "aws_iam_policy_document" "ec2_dynamodb_policy" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]

    effect = "Allow"

    resources = [aws_dynamodb_table.flaks_app.arn]
  }
}

resource "aws_iam_role_policy" "ec2_dynamodb_policy" {
  name = "ec2-dynamodb-policy"
  role = aws_iam_role.ec2_dynamodb_role.id

  policy = data.aws_iam_policy_document.ec2_dynamodb_policy.json
}


