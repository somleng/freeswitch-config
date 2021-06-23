output "rayo_password_parameter" {
  value = aws_ssm_parameter.rayo_password
  sensitive = true
}

output "inbound_sip_trunks_security_group" {
  value = aws_security_group.appserver
}
