variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  packageServerKey = "operators.coreos.com/ClusterServiceVersion/olm/packageserver"
  ids-this-stage0  = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = toset(var.deploy ? [
    for id in data.kustomization_overlay.this.ids_prio[1] :
    id if id != local.packageServerKey] : []
  )
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
}
data "kustomization_overlay" "this" {
  resources = concat(
    [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"],
    [
      var.paths.olm-crd,
      var.paths.olm-olm,
    ]
  )
  # namespace = "olm"
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
resource "kubectl_manifest" "olm_operator_packageserver" {
  for_each = {
    "${local.packageServerKey}" = data.kustomization_overlay.this.manifests[local.packageServerKey]
  }
  yaml_body         = each.value
  server_side_apply = true
  wait              = true
  ignore_fields = [
    "spec.version",
    "spec.install.spec.deployments",
    ".spec.version",
    ".spec.install.spec.deployments",
  ]
  depends_on = [
    kubectl_manifest.stage2,
  ]
}
resource "time_sleep" "operator-wait" {
  depends_on = [kubectl_manifest.olm_operator_packageserver]

  create_duration = "60s"
}
