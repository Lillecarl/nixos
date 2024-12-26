terraform {
  backend "kubernetes" {
    secret_suffix = "keycloak"
    namespace     = "default"
  }
}
