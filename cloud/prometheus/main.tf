variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-bundle-stage0 = toset([
    for id in data.kustomization_overlay.bundle.ids_prio[0] :
    id if !strcontains(id, "CustomResourceDefinition")
  ])
  ids-bundle-stage1  = var.deploy ? data.kustomization_overlay.bundle.ids_prio[1] : []
  ids-bundle-stage2  = var.deploy ? data.kustomization_overlay.bundle.ids_prio[2] : []
  ids-cluster-stage0 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[0] : []
  ids-cluster-stage1 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[1] : []
  ids-cluster-stage2 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[2] : []
}
data "kustomization_overlay" "bundle" {
  resources = concat(
    [var.paths.prometheus-bundle],
    [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}" if startswith(file, "bundle_")]
  )
  namespace = "prometheus"
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
data "kustomization_overlay" "cluster" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}" if !startswith(file, "bundle_")]
  namespace = "prometheus"
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "bundle-stage0" {
  for_each   = local.ids-bundle-stage0
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "bundle-stage1" {
  for_each   = local.ids-bundle-stage1
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = [kubectl_manifest.bundle-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "bundle-stage2" {
  for_each   = local.ids-bundle-stage2
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = [kubectl_manifest.bundle-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cluster-stage0" {
  for_each  = local.ids-cluster-stage0
  yaml_body = data.kustomization_overlay.cluster.manifests[each.value]
  depends_on = [
    kubectl_manifest.bundle-stage1,
    kubectl_manifest.bundle-stage2,
  ]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cluster-stage1" {
  for_each   = local.ids-cluster-stage1
  yaml_body  = data.kustomization_overlay.cluster.manifests[each.value]
  depends_on = [kubectl_manifest.cluster-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cluster-stage2" {
  for_each   = local.ids-cluster-stage2
  yaml_body  = data.kustomization_overlay.cluster.manifests[each.value]
  depends_on = [kubectl_manifest.cluster-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
