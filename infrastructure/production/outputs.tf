output "rayo_password_parameter" {
  value = module.somleng_freeswitch.rayo_password_parameter
  sensitive = true
}

output "inbound_sip_trunks_security_group" {
  value = module.somleng_freeswitch.inbound_sip_trunks_security_group
}
