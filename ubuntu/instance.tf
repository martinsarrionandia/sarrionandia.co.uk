data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "creation-date"
    values = ["2024-01-26T*"]
  }
}

resource "aws_instance" "sarrionandia" {
  availability_zone    = var.availability_zone
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.medium"
  key_name             = var.instance_key_name
  iam_instance_profile = aws_iam_instance_profile.sarrionandia.id
  root_block_device {
    volume_type = "gp3"
    volume_size = "16"
    tags = {
      Name = local.sarrionandia_fqdn
    }
  }
  network_interface {
    network_interface_id = aws_network_interface.sarrionandia.id
    device_index         = 0
  }

  tags = {
    Name    = local.sarrionandia_fqdn
    Rancher = "True"
  }

  provisioner "local-exec" {
    command = "ssh-keygen -R ${self.tags.Name}"
    when    = destroy
  }
}

resource "aws_network_interface" "sarrionandia" {
  subnet_id       = data.aws_subnet.legacy.id
  security_groups = [data.aws_security_group.legacy_mgmt.id, data.aws_security_group.legacy_ingress.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_eip" "sarrionandia" {
  network_interface = aws_network_interface.sarrionandia.id
}

locals {
  sarrionandia_fqdn = "sarrionandia.co.uk"
}

resource "aws_volume_attachment" "wordpress_icons" {
  device_name = "/dev/sdf"
  volume_id   = data.aws_ebs_volume.wordpress_icons.id
  instance_id = aws_instance.sarrionandia.id
}

resource "aws_volume_attachment" "wordpress_djmaddox" {
  device_name = "/dev/sdg"
  volume_id   = data.aws_ebs_volume.wordpress_djmaddox.id
  instance_id = aws_instance.sarrionandia.id
}

resource "aws_volume_attachment" "sarrionandia_maria" {
  device_name = "/dev/sdh"
  volume_id   = data.aws_ebs_volume.sarrionandia_maria.id
  instance_id = aws_instance.sarrionandia.id
}

resource "aws_volume_attachment" "wordpress_djmaddox_images" {
  device_name = "/dev/sdi"
  volume_id   = data.aws_ebs_volume.wordpress_djmaddox_images.id
  instance_id = aws_instance.sarrionandia.id
}