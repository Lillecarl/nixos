variable "BITWARDEN_MACHINE_KEY" {}
variable "paths" { type = map(string) }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  namespace       = "external-secrets"
  helm_values = {
    bitwarden-sdk-server = { enabled = true }
    certController       = { loglevel = "debug" }
  }
}
data "kubernetes_resource" "cabundle" {
  api_version = "v1"
  kind        = "Secret"

  metadata {
    name      = "root-secret"
    namespace = "cert-manager"
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = local.namespace
  secret_generator {
    name = "bitwarden-access-token"
    type = "Opaque"
    literals = [
      "token=${var.BITWARDEN_MACHINE_KEY}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name         = "external-secrets"
    namespace    = local.namespace
    repo         = "https://charts.external-secrets.io"
    release_name = "external-secrets"
    # version       = "8.7.1"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  patches {
    patch = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: bitwarden-secretsmanager
spec:
  provider:
    bitwardensecretsmanager:
      caBundle: ${data.kubernetes_resource.cabundle.object.data["ca.crt"]}
YAML
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

  apply_only        = true
  server_side_apply = true
  wait              = true
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  server_side_apply = true
  wait              = true
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  server_side_apply = true
  wait              = true
}
