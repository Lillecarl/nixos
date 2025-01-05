variable "htpasswd" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  namespace       = "registry"
  helm_values = {
    ui = {
      title             = "Container Registry"
      image             = "joxit/docker-registry-ui:2.5.7"
      deleteImages      = true
      showContentDigest = true
      ingress = {
        enabled = true
        host    = "registry.lillecarl.com"
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-staging"
        }
        tls = [{
          secretName = "registry-tls"
          hosts      = ["registry.lillecarl.com"]
        }]
      }
    }
    registry = {
      enabled = true
      image   = "registry:2.8.3"
      auth = { basic = {
        enabled    = true
        realm      = "Container Registry"
        secretName = "registry-htpasswd"
      } }
      ingress = {
        enabled = true
        host    = "registry.lillecarl.com"
        annotations = {
          "cert-manager.io/cluster-issuer"              = "letsencrypt-staging"
          "nginx.ingress.kubernetes.io/proxy-body-size" = "2g"
        }
        tls = [{
          secretName = "registry-tls"
          hosts      = ["registry.lillecarl.com"]
        }]
      }
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = local.namespace
  secret_generator {
    name      = "registry-htpasswd"
    namespace = local.namespace
    type      = "Opaque"
    literals = [
      "htpasswd=regadm:${var.htpasswd}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "docker-registry-ui"
    release_name  = "docker-registry-ui"
    namespace     = local.namespace
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  helm_globals {
    chart_home = var.paths.charts
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = local.ids-this-stage0
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
