resource "aws_cloudwatch_log_group" "flask_app" {
  name              = "/ecs/awslab-cloud-flask-app-${var.env}"
  retention_in_days = 30

  tags = {
    Name = "awslab-flask-app-${var.env}"
  }
}

resource "aws_cloudwatch_log_stream" "flask_app" {
  name           = "awslab-flask-app"
  log_group_name = aws_cloudwatch_log_group.flask_app.name
}