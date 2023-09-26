data "aws_region" "current" {}
/*
data "terraform_remote_state" "flask_app" {
  backend = "s3"
  config = {
    bucket = "gsiders-tf"
    key = "awslab-cloud/flask-app/terraform.tfstate"
    region = "us-east-1"
  }
}
*/
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

    resources = ["*"]
  }
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