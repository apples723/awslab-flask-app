resource "aws_alb" "flask_app" {
  name               = "flask-app-load-balancer"
  load_balancer_type = "network"

  security_groups = [aws_security_group.flask_ecs.id]
  subnet_mapping {
    allocation_id = aws_eip.flask_app_lb[0].allocation_id
    subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  }
  subnet_mapping {
    allocation_id = aws_eip.flask_app_lb[1].allocation_id
    subnet_id     = data.terraform_remote_state.vpc.outputs.public_subnet_ids[1]
  }
}

resource "aws_alb_target_group" "flask_app" {
  name        = "flask-app-target-group"
  port        = var.app_port
  protocol    = "TLS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"



  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "TCP"
    timeout             = "3"
    unhealthy_threshold = "4"
  }

}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.flask_app.id
  port              = var.app_port
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.flask_app_alb.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06"

  default_action {
    target_group_arn = aws_alb_target_group.flask_app.id
    type             = "forward"
  }

  depends_on = [aws_alb.flask_app]
}

resource "aws_eip" "flask_app_lb" {
  count = 2
  tags = {
    Name = "flask-app-ecs-lb-${count.index + 1}"
  }
}

resource "aws_alb_listener_certificate" "flask_latency" {
  certificate_arn = aws_acm_certificate.flask_app_latency.arn
  listener_arn = aws_alb_listener.front_end.arn
}