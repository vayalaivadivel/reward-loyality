output "role_name" {
  value = aws_iam_role.this.name
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "dms_role_arn" {
  value = aws_iam_role.dms_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}