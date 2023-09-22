terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    region = "us-east-1"
    key    = "aws-cert/infra/terraform.tfstate"
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


#Flask App Status SSM

resource "aws_ssm_parameter" "flask_app_status" {
  name  = "/slalom-awslab-cloud/flask-app/http-status-code"
  type  = "String"
  value = "200"
}


data "aws_iam_policy_document" "ec2_ssm_param_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DeleteParameter"
    ]
    effect = "Allow"

    resources = [aws_ssm_parameter.flask_app_status.arn]
  }
}

resource "aws_iam_role_policy" "ec2_ssm_policy" {
  name   = "awslab-ec2-ssm-param-policy"
  role   = aws_iam_role.ec2_role.name
  policy = data.aws_iam_policy_document.ec2_ssm_param_policy.json
}



#EC2 instance profile

resource "aws_iam_instance_profile" "flask_app" {
  name = "awslab-ec2-flask-app-instance-profile"
  role = aws_iam_role.ec2_role.name
}

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

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.flask_app.name
}