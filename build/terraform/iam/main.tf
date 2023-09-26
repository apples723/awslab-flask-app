variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "awslab-cloud-ecs-task-execution"
}

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


#ECS Roles

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}