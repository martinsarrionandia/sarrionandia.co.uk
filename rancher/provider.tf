# AWS Provider 
provider "aws" {
  region = "eu-west-2"
}

# Helm Provider
provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

# Kubernetes Provider
provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
}