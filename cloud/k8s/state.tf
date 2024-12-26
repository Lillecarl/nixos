terraform {
  backend "kubernetes" {
    secret_suffix = "k8s"
    namespace     = "default"
  }
}
