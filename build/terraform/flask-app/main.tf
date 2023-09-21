locals {
  private_subnet_ids = data.terraform_remote_state.infra.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.infra.outputs.public_subnet_ids
  ec2_role_name = data.terraform_remote_state.infra.outputs.ec2_role_name
  vpc_id             = data.terraform_remote_state.infra.outputs.vpc_id
  ec2_instance_profile_name = data.terraform_remote_state.infra.outputs.ec2_instance_profile_name
  hosted_zone_id     = "Z0929837KI7V4LSZF7ZR"
  az_letters         = ["a", "b", "c", "d"]
  dns_weights        = ["200", "100"]
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
  role   = local.ec2_role_name
  policy = data.aws_iam_policy_document.ec2_ssm_param_policy.json
}

#Security Group 
resource "aws_security_group" "flask_app" {
  vpc_id = local.vpc_id
  tags = {
    Name = "flask-app-sg"
  }
}

#allows access from the IP of where the apply is ran
resource "aws_security_group_rule" "my_ip" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.my_ip.response_body}/32"]
  security_group_id = aws_security_group.flask_app.id
}

#allows access from my home public IP
resource "aws_security_group_rule" "home_ip" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.home_ip.response_body}/32"]
  security_group_id = aws_security_group.flask_app.id
}


resource "aws_security_group_rule" "outbound" {
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_app.id
}

#instances 

resource "aws_instance" "flask_app" {
  count               = length(local.public_subnet_ids)
  key_name               = "gsiders-uswe2"
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.flask_app.id]
  subnet_id              = local.public_subnet_ids[count.index]
  iam_instance_profile = local.ec2_instance_profile_name
  tags = {
    Name = "flask-app-${local.az_letters[count.index]}"
  }
}

resource "aws_eip" "flask_app" {
  count = length(aws_instance.flask_app)
  instance = aws_instance.flask_app[count.index].id
  tags = {
    Name = "flask-app-${local.az_letters[count.index]}"
  }
  depends_on = [ aws_instance.flask_app ]
}

resource "aws_route53_record" "flask_app" {
  count = length(aws_eip.flask_app)
  name    = "flask-app-${local.az_letters[count.index]}"
  type    = "A"
  ttl = 300
  zone_id = local.hosted_zone_id
  records = [aws_eip.flask_app[count.index].public_ip]
  depends_on = [ aws_eip.flask_app ]
}

