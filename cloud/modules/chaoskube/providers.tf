terraform {
  required_providers {
    kustomization = {
      source = "kbst/kustomization"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}
