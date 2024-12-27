variable "stage0" { type = bool }
variable "stage1" { type = bool }
variable "stage2" { type = bool }
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
locals {
  stage0-ids = var.stage0 ? data.kustomization_overlay.this.ids_prio[0] : []
  stage1-ids = var.stage1 ? data.kustomization_overlay.this.ids_prio[1] : []
  stage2-ids = var.stage2 ? data.kustomization_overlay.this.ids_prio[2] : []
}
data "kustomization_overlay" "this" {
  resources = concat(
    [var.paths.cnpg-bundle],
    [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"],
  )
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
output "kustomization" { value = data.kustomization_overlay.this }
resource "kubectl_manifest" "stage0" {
  for_each   = local.stage0-ids
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.stage1-ids
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.stage2-ids
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]
  # kubestack people recommend applying stage 2 (MutatingWebhookConfiguration
  # and ValidatingWebhookConfiguration) after all other resources. This is invalid
  # for CNPG since it uses the hooks for setting up some PKI infra

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
