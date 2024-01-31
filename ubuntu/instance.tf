data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04"

  filter {
    name   = "architecture"
    values = ["x86_64"]

  }
}

resource "aws_instance" "sarrionandia" {
  availability_zone = var.availability_zone
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.medium"
  key_name          = var.instance_key_name
  root_block_device {
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