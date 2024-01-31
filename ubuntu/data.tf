data "aws_subnet" "legacy" {
  filter {
    name   = "tag:Name"
    values = ["Legacy subnet"]
  }
}

data "aws_security_group" "legacy_mgmt" {
  name = "Legacy Mgmt"
}

data "aws_security_group" "legacy_ingress" {
  name = "Legacy Ingress"
}