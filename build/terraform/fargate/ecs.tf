resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

data "template_file" "flask_app" {
  template = file("./templates/flask_app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_tag        = var.app_tag
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "flask_app" {
  family                   = "awslab-flask-app"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.flask_app.rendered
  runtime_platform {
    cpu_architecture = "ARM64"
  }
  depends_on = [aws_alb.flask_app, aws_alb_target_group.flask_app, aws_alb_listener.front_end]
}

resource "aws_ecs_service" "main" {
  name                 = "flask-app-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.flask_app.arn
  desired_count        = var.app_count
  launch_type          = "FARGATE"
  force_new_deployment = var.force_update

  network_configuration {
    security_groups  = [aws_security_group.flask_ecs.id]
    subnets          = data.terraform_remote_state.vpc.outputs.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.flask_app.id
    container_name   = "awslab-flask-app"
    container_port   = var.app_port
  }
  depends_on = [aws_alb.flask_app, aws_alb_listener.front_end, aws_alb_target_group.flask_app]
}
