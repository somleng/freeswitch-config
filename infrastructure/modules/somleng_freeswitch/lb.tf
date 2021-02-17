resource "aws_lb_target_group" "rayo" {
  name        = "${var.app_identifier}-rayo"
  port        = var.rayo_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "sip" {
  name        = "${var.app_identifier}-sip"
  port        = var.sip_port
  protocol    = "UDP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    port = var.rayo_port
    protocol = "TCP"
  }
}
