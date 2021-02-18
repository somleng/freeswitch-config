output "rayo_security_group" {
  value = aws_security_group.rayo
}

output "rayo_password_parameter" {
  value = aws_ssm_parameter.rayo_password
  sensitive = true
}
