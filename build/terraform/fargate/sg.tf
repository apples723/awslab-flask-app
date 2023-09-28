locals {
  den_office_cidrs = ["209.249.246.202/32"]
}
#Security Group 
resource "aws_security_group" "flask_ecs" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = {
    Name = "flask-ecs-sg"
  }
}

#allows access from the IP of where the apply is ran
resource "aws_security_group_rule" "my_ip" {
  count             = 0
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.my_ip.response_body}/32"]
  security_group_id = aws_security_group.flask_ecs.id
}


#allows access from my home public IP
resource "aws_security_group_rule" "home_ip" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.home_ip.response_body}/32"]
  security_group_id = aws_security_group.flask_ecs.id
}

#allows access from my home public IP
resource "aws_security_group_rule" "den_office" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = local.den_office_cidrs
  security_group_id = aws_security_group.flask_ecs.id
}


resource "aws_security_group_rule" "outbound" {
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_ecs.id
}

output "sg_id" {
  value = aws_security_group.flask_ecs.id
}