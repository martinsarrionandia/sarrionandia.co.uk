data "aws_ebs_snapshot" "djmaddox_wordpress" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["wordpress_djmaddox"]
  }
}

data "aws_ebs_snapshot" "sarrionandia_maria" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["sarrionandia.co.uk_maria"]
  }
}

resource "aws_ebs_volume" "djmaddox_wordpress" {
  availability_zone = "eu-west-2a"
  type = "gp3"
  snapshot_id = data.aws_ebs_snapshot.djmaddox_wordpress.snapshot_id

  tags = data.aws_ebs_snapshot.djmaddox_wordpress.tags

}

resource "aws_ebs_volume" "sarrionandia_maria" {
  availability_zone = "eu-west-2a"
  type = "gp3"
  snapshot_id = data.aws_ebs_snapshot.sarrionandia_maria.snapshot_id

  tags = data.aws_ebs_snapshot.sarrionandia_maria.tags

}