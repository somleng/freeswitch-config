variable "ecs_cluster" {}
variable "app_identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "memory" {}
variable "cpu" {}
variable "aws_region" {}
variable "container_instance_subnets" {}
variable "vpc_id" {}
variable "load_balancer_arn" {}

variable "rayo_port" {
  default = 5222
}

variable "sip_port" {
  default = 5060
}

variable "network_mode" {
  default = "awsvpc"
}
variable "launch_type" {
  default = "FARGATE"
}

variable "db_host" {
}

variable "db_port" {
}

variable "db_security_group" {
}

variable "db_username" {}
variable "db_password_parameter_arn" {}
variable "json_cdr_password_parameter_arn" {}
variable "rayo_user" {}
variable "rayo_host" {}
variable "external_ip" {}

variable "enable_dashboard" {
  default = false
}
variable "ecs_appserver_autoscale_max_instances" {
  default = 4
}
variable "ecs_appserver_autoscale_min_instances" {
  default = 1
}
# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "80"
}
