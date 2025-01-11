variable "grafana-admin-pass" {}
variable "grafana-client-secret" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  grafana-url     = "grafana.lillecarl.com"
  helm_values = {
    assertNoLeakedSecrets = false
    admin = {
      existingSecret = "admin"
      userKey        = "username"
      passwordKey    = "password"
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      annotations      = { "cert-manager.io/cluster-issuer" = "letsencrypt-staging" }
      hosts            = [local.grafana-url]
      tls = [{
        hosts      = [local.grafana-url]
        secretName = "tls"
      }]
    }
    persistence = {
      enabled          = true
      storageClassName = "local-path"
      size             = "1Gi"
    }
    "grafana.ini" = {
      analytics = { check_for_updates = false }
      server = {
        root_url = "https://${local.grafana-url}"
      }
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "grafana"
  helm_charts {
    name          = "grafana"
    release_name  = "grafana"
    namespace     = "grafana"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  secret_generator {
    name = "admin"
    type = "Opaque"
    literals = [
      "username=admin",
      "password=${var.grafana-admin-pass}",
    ]
    options { disable_name_suffix_hash = true }
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
