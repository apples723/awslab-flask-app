resource "aws_instance" "flask_app" {
  count               = length(local.public_subnet_ids)
  key_name               = "gsiders-uswe2"
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.flask_app.id]
  subnet_id              = local.public_subnet_ids[count.index]
  iam_instance_profile = local.ec2_instance_profile_name
  user_data_base64 = data.local_file.user_data.content_base64
  user_data_replace_on_change = true
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


#Security Group 
resource "aws_security_group" "flask_app" {
  vpc_id = local.vpc_id
  tags = {
    Name = "flask-app-sg"
  }
}

#allows access from the IP of where the apply is ran
resource "aws_security_group_rule" "my_ip" {
  count = 0
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
output "sg_id" {
  value = aws_security_group.flask_app.id
}

#R53 records for each instance

resource "aws_route53_record" "flask_app" {
  count = length(aws_eip.flask_app)
  name    = "flask-app-${local.az_letters[count.index]}-${local.region_shorthand[data.aws_region.current.name]}"
  type    = "A"
  ttl = 300
  zone_id = local.hosted_zone_id
  records = [aws_eip.flask_app[count.index].public_ip]
  depends_on = [ aws_eip.flask_app ]
}

output "flask_app_eips" {
  value = [ for i in aws_eip.flask_app : i.public_ip ]
}
