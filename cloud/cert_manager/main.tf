variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
variable "CF_DNS_TOKEN" {}
locals {
  ids-chart-stage0  = data.kustomization_overlay.chart.ids_prio[0]
  ids-chart-stage1  = var.deploy ? data.kustomization_overlay.chart.ids_prio[1] : []
  ids-chart-stage2  = var.deploy ? data.kustomization_overlay.chart.ids_prio[2] : []
  ids-config-stageX = var.deploy ? data.kustomization_overlay.config.ids : []
  cert-manager-values = {
    dns01RecursiveNameservers     = "1.1.1.1:53,1.0.0.1:53"
    dns01RecursiveNameserversOnly = true
    crds                          = { enabled = true }
    prometheus = {
      servicemonitor = { enabled = true }
    }
  }
  trust-manager-values = {
    # secretTargets = { enabled = true }
  }
}
data "kustomization_overlay" "chart" {
  # If you set namespace here cert-manager dies
  helm_charts {
    name          = "cert-manager"
    namespace     = "cert-manager"
    repo          = "https://charts.jetstack.io"
    release_name  = "cert-manager"
    version       = "1.16.2"
    include_crds  = true
    values_inline = yamlencode(local.cert-manager-values)
  }
  helm_charts {
    name         = "cert-manager-csi-driver"
    namespace    = "cert-manager"
    repo         = "https://charts.jetstack.io"
    release_name = "cert-manager-csi-driver"
    include_crds = true
  }
  helm_charts {
    name          = "trust-manager"
    namespace     = "cert-manager"
    repo          = "https://charts.jetstack.io"
    release_name  = "trust-manager"
    include_crds  = true
    values_inline = yamlencode(local.trust-manager-values)
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
data "kustomization_overlay" "config" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  patches {
    target {
      kind = "Certificate"
      name = "example-tld"
    }
    patch = <<YAML
kind: Certificate
metadata:
  name: lillecarl-com
  namespace: default
spec:
  secretName: lillecarl-com-tls
  dnsNames:
    - lillecarl.com
    - www.lillecarl.com
YAML
    options {
      allow_name_change = true
    }
  }
  secret_generator {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
    type      = "Opaque"
    literals = [
      "api-token=${var.CF_DNS_TOKEN}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "chart-stage0" {
  for_each   = local.ids-chart-stage0
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "chart-stage1" {
  for_each   = local.ids-chart-stage1
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = [kubectl_manifest.chart-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "chart-stage2" {
  for_each   = local.ids-chart-stage2
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = [kubectl_manifest.chart-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "time_sleep" "cert_wait" {
  count      = var.deploy ? 1 : 0
  depends_on = [kubectl_manifest.chart-stage2]

  create_duration = "60s"
}
resource "kubectl_manifest" "config-stageX" {
  for_each   = local.ids-config-stageX
  yaml_body  = data.kustomization_overlay.config.manifests[each.value]
  depends_on = [time_sleep.cert_wait]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
