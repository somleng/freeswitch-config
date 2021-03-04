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

resource "aws_lb_listener" "rayo" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.rayo_port
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rayo.arn
  }
}

resource "aws_lb_listener" "sip" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.sip_port
  protocol          = "UDP"
  # https://github.com/hashicorp/terraform-provider-aws/issues/17227
  # connection_termination = true

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.sip.arn
  }
}
