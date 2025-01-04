terraform {
  required_providers {
    kustomization = {
      source = "registry.opentofu.org/kbst/kustomization"
    }
    kubectl = {
      source = "registry.opentofu.org/alekc/kubectl"
    }
    kubernetes = {
      source = "registry.opentofu.org/hashicorp/kubernetes"
    }
    vault = {
      source = "registry.opentofu.org/hashicorp/vault"
    }
    http = {
      source = "registry.opentofu.org/hashicorp/http"
    }
    local = {
      source = "registry.opentofu.org/hashicorp/local"
    }
    htpasswd = {
      source = "registry.opentofu.org/loafoe/htpasswd"
    }
    keycloak = {
      source = "registry.opentofu.org/keycloak/keycloak"
    }
    string-functions = {
      source = "registry.opentofu.org/random-things/string-functions"
    }
    postgresql = {
      source = "registry.opentofu.org/cyrilgdn/postgresql"
    }
    random = {
      source = "hashicorp/random"
    }
    migadu = {
      source = "registry.opentofu.org/metio/migadu"
    }
  }
}
provider "kubectl" {
  apply_retry_count = 1
}
