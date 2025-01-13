locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = data.kustomization_overlay.this.ids_prio[1]
  ids-this-stage2 = data.kustomization_overlay.this.ids_prio[2]
  namespace       = "grafana-operator"
  helm_values     = {}
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = local.namespace
  helm_charts {
    name          = "grafana-operator"
    release_name  = "grafana-operator"
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

  # Don't remove namespace and CRD if uninstalling
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
