variable "keycloak_db_pass" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-bundle-stage0  = data.kustomization_overlay.bundle.ids_prio[0]
  ids-bundle-stage1  = var.deploy ? data.kustomization_overlay.bundle.ids_prio[1] : []
  ids-bundle-stage2  = var.deploy ? data.kustomization_overlay.bundle.ids_prio[2] : []
  ids-cluster-stage0 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[0] : []
  ids-cluster-stage1 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[1] : []
  ids-cluster-stage2 = var.deploy ? data.kustomization_overlay.cluster.ids_prio[2] : []
}
data "kustomization_overlay" "bundle" {
  resources = [var.paths.cnpg-bundle]
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
  depends_on = [kubectl_manifest.bundle-stage0]
  # kubestack people recommend applying bundle-stage 2 (MutatingWebhookConfiguration
  # and ValidatingWebhookConfiguration) after all other resources. This is invalid
  # for CNPG since it uses the hooks for setting up some PKI infra

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
data "kustomization_overlay" "cluster" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "pg-cluster"
  secret_generator {
    name = "cluster-keycloak"
    type = "Opaque"
    literals = [
      "username=keycloak",
      "password=${var.keycloak_db_pass}",
    ]
    options {
      disable_name_suffix_hash = true
      labels = {
        "cnpg.io/reload" = true
      }
    }
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
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
