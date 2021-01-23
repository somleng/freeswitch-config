resource "aws_ecr_repository" "app" {
  name                 = "somleng-freeswitch"

  image_scanning_configuration {
    scan_on_push = true
  }
}
