output "rayo_password_parameter" {
  value = aws_ssm_parameter.rayo_password
  sensitive = true
}
