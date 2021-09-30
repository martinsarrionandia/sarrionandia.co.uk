data "aws_ebs_volume" "wordpress_root" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = ["sarrionandia.co.uk-wordpress-root"]
  }
}

data "aws_ebs_volume" "wordpress_maria" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp3"]
  }

  filter {
    name   = "tag:Name"
    values = ["sarrionandia.co.uk-wordpress-maria"]
  }
}

resource "kubernetes_persistent_volume" "wordpress_root" {
  metadata {
    name = "sarrionandia.co.uk-wordpress-root"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store { 
          volume_id = data.aws_ebs_volume.wordpress_root.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_root" {
  metadata {
    name = "sarrionandia.co.uk-wordpress-root-claim"
    namespace = kubernetes_namespace.sarrionandia.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress_root.metadata.0.name
  }
}


resource "kubernetes_persistent_volume" "wordpress_maria" {
  metadata {
    name = "sarrionandia.co.uk-wordpress-maria"
    labels = {
      type = "amazonEBS"
    }
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store { 
          volume_id = data.aws_ebs_volume.wordpress_maria.id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress_maria" {
  metadata {
    name = "sarrionandia.co.uk-wordpress-maria-claim"
    namespace = kubernetes_namespace.sarrionandia.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.wordpress_maria.metadata.0.name
  }
}