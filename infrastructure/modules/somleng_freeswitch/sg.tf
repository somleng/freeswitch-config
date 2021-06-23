resource "aws_security_group" "appserver" {
  name   = "${var.app_identifier}-appserver"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "appserver_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.appserver.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rayo" {
  type        = "ingress"
  from_port   = var.rayo_port
  to_port     = var.rayo_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Rayo"

  security_group_id = aws_security_group.appserver.id
}
