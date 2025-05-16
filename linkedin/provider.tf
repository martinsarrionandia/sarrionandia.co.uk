# AWS Provider 
provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Environment = "Container"
      Managedby   = "Terraform"
      Rancher     = "True"
    }
  }
}

# Helm Provider
provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}
