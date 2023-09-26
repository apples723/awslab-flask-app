output "ec2_role_id" {
  value = aws_iam_role.ec2_role.id
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.flask_app.name
}