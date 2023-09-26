#Flask App HTTP Status

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
