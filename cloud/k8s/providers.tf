terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
    helm = {
      source = "hashicorp/helm"
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
  }
}

provider "kustomization" {
  # Configuration options
}
provider "kubernetes" {
  # Configuration options
}
provider "kubectl" {
  # Configuration options
}
provider "http" {
  # Configuration options
}
provider "local" {
  # Configuration options
}
provider "helm" {
  # Configuration options
}
