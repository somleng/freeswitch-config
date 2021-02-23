data "aws_ssm_parameter" "twilreapi_services_password" {
  name = "twilreapi.production.services_password"
}

module "somleng_freeswitch" {
  source = "../modules/somleng_freeswitch"

  ecs_cluster = data.terraform_remote_state.core_infrastructure.outputs.ecs_cluster
  app_identifier = "somleng-freeswitch"
  app_environment = "production"
  app_image = data.terraform_remote_state.core.outputs.app_ecr_repository
  memory = 1024
  cpu = 512
  aws_region = var.aws_region
  container_instance_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.private_subnets
  vpc_id = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_id
  json_cdr_password_parameter_arn = data.aws_ssm_parameter.twilreapi_services_password.arn

  load_balancer_arn = data.terraform_remote_state.core_infrastructure.outputs.network_load_balancer.arn

  db_username = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db_master_password_parameter.arn
  db_host = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_endpoint
  db_port = data.terraform_remote_state.core_infrastructure.outputs.db.this_rds_cluster_port
  db_security_group = data.terraform_remote_state.core_infrastructure.outputs.db_security_group.id
  external_ip = data.terraform_remote_state.core_infrastructure.outputs.vpc.nat_public_ips[0]
  rayo_user = "rayo"
  rayo_host = "rayo.somleng.org"
  json_cdr_url = "https://twilreapi.somleng.org/services/call_data_records"

  ecs_appserver_autoscale_min_instances = 1
}
