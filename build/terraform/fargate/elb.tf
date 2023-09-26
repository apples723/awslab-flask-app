resource "aws_alb" "flask_app" {
  name            = "flask-app-load-balancer"
  load_balancer_type = "network"
  security_groups = [data.terraform_remote_state.flask_app.outputs.sg_id]
  subnet_mapping {
    allocation_id = aws_eip.flask_app_lb[0].allocation_id
    subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  }
  subnet_mapping {
    allocation_id = aws_eip.flask_app_lb[1].allocation_id
    subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[1]
  }
}

resource "aws_alb_target_group" "flask_app" {
  name        = "flask-app-target-group"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"


  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/health/good"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.flask_app.id
  port              = var.app_port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_alb_target_group.flask_app.id
    type             = "forward"
  }

}

resource "aws_eip" "flask_app_lb" {
  count = 2
  tags = {
    Name = "flask-app-ecs-lb-${count.index+1}"
  }
}
