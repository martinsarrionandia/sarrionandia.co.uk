resource "kubernetes_namespace" "sarrionandia" {
  metadata {
    name = "sarrionandia-wordpress"
  }
}