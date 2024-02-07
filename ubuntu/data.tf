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

data "aws_ebs_volume" "wordpress_icons" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["wordpress_icons"]
  }
}

data "aws_ebs_volume" "wordpress_djmaddox" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["wordpress_djmaddox"]
  }
}

data "aws_ebs_volume" "sarrionandia_maria" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["sarrionandia.co.uk_maria"]
  }
}

data "aws_ebs_volume" "wordpress_djmaddox_images" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["wordpress_djmaddox_images"]
  }
}

