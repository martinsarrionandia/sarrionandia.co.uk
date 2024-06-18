data "aws_ebs_snapshot" "icons_wordpress" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["wordpress_icons"]
  }
}



resource "aws_ebs_volume" "icons_wordpress" {
  availability_zone = "eu-west-2a"
  type = "gp3"
  snapshot_id = data.aws_ebs_snapshot.icons_wordpress.snapshot_id

  tags = data.aws_ebs_snapshot.icons_wordpress.tags

}

