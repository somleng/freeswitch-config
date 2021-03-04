resource "aws_cloudwatch_log_group" "app" {
  name = "${var.app_identifier}-app"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name = "${var.app_identifier}-flow_logs"
  retention_in_days = 7
}

