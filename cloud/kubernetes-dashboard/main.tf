locals {
  namespace = "kubernetes-dashboard"
  chart     = "kubernetes-dashboard"
  helm_values = {
    kong = { enabled = false }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = local.namespace
  helm_charts {
    name          = local.chart
    release_name  = local.chart
    namespace     = local.namespace
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  helm_globals {
    chart_home = local.chartParentPath
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helmBinPath
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = data.kustomization_overlay.this.ids_prio[0]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = data.kustomization_overlay.this.ids_prio[1]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = data.kustomization_overlay.this.ids_prio[2]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
