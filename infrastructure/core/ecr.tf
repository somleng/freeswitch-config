resource "aws_ecrpublic_repository" "app" {
  repository_name = "somleng-freeswitch"
  provider = aws.us-east-1

  catalog_data {
    about_text        = "Somleng FreeSWITCH"
    architectures     = ["Linux"]
    description       = "FreeSWITCH configuration optimized for Somleng"
  }
}
