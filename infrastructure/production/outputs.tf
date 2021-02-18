output "rayo_security_group" {
  value = module.somleng_freeswitch.rayo_security_group
}

output "rayo_password_parameter" {
  value = module.somleng_freeswitch.rayo_password_parameter
  sensitive = true
}
