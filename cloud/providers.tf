terraform {
  required_providers {
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    kustomization = {
      source = "kbst/kustomization"
    }
    kubectl = {
      source = "alekc/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    vault = {
      source = "hashicorp/vault"
    }
    http = {
      source = "hashicorp/http"
    }
    local = {
      source = "hashicorp/local"
    }
    htpasswd = {
      source = "loafoe/htpasswd"
    }
    keycloak = {
      source = "keycloak/keycloak"
    }
    string-functions = {
      source = "random-things/string-functions"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    random = {
      source = "hashicorp/random"
    }
    migadu = {
      source = "metio/migadu"
    }
  }
}
provider "kubectl" {
  apply_retry_count = 1
}
provider "bitwarden" {
  experimental {
    embedded_client = true
  }
}
