terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}
provider "keycloak" {
  client_id                = "terraform"
  url                      = "https://keycloak.lillecarl.com"
  tls_insecure_skip_verify = true
}
