terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.2.1"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
    string-functions = {
      source  = "registry.terraform.io/random-things/string-functions"
      version = "0.2.0"
    }
  }
}
provider "kubectl" {
  apply_retry_count = 1
}
