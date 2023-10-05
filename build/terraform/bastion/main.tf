terraform {
  backend "s3" {
    bucket = "gsiders-tf"
    key = "awslab-cloud/bastion/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

variable "key_pair_name" {}
variable "region" {}

locals {
  env = split("-", terraform.workspace)[1]
  name = "${local.env}-bastion"
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}

resource "aws_security_group" "bastion" {
  description = "SSH Access for ${local.env} Bastion Host"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "${local.env} Bastion SSH Security Group"
}

#allows access from the IP of where the apply is ran
resource "aws_security_group_rule" "my_ip" {
  count             = 0
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.my_ip.response_body}/32"]
  security_group_id = aws_security_group.bastion.id
}


#allows access from my home public IP
resource "aws_security_group_rule" "home_ip" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["${data.http.home_ip.response_body}/32"]
  security_group_id = aws_security_group.bastion.id
}

#allows vpc cidr 
resource "aws_security_group_rule" "vpc_cidr" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.bastion.id
}


resource "aws_security_group_rule" "outbound" {
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

module "bastion" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "5.5.0"
  name                        = local.name
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = local.public_subnet_ids[0]
  associate_public_ip_address = true
}

resource "aws_eip" "bastion" {
  instance = module.bastion.id
  tags = {
    Name = "${local.name}-eip"
  }
}

output "bastion_eip" {
  value = aws_eip.bastion.public_ip
}

resource "aws_route53_record" "bastion" {
  name = "bastion"
  type = "A"
  zone_id = data.terraform_remote_state.r53.outputs.env_zone_id
  ttl = "300"
  records = [ aws_eip.bastion.public_ip  ]
}