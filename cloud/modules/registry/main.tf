locals {
  htpasswd = "regadm:${var.registry_secret["bcrypt"]}"
  dockerconfigjson = base64encode(jsonencode({
    auths = {
      "registry.lillecarl.com" = {
        auth = base64encode("regadm:${var.registry_secret["password"]}")
      }
    }
  }))
}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "registry_secret" { type = map(string) }
data "kustomization_overlay" "this" {
  namespace = "registry"
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  secret_generator {
    name      = "registry-secret"
    namespace = "registry"
    type      = "Opaque"
    literals = [
      "htpasswd=${local.htpasswd}",
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
output "kustomization" { value = data.kustomization_overlay.this }
resource "kubectl_manifest" "stage0" {
  for_each   = data.kustomization_overlay.this.ids_prio[0]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = data.kustomization_overlay.this.ids_prio[1]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = data.kustomization_overlay.this.ids_prio[2]
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "regcred" {
  yaml_body  = <<YAML
apiVersion: v1
data:
  .dockerconfigjson: ${local.dockerconfigjson}
kind: Secret
metadata:
  name: regcred
  namespace: default
type: kubernetes.io/dockerconfigjson
YAML
  depends_on = [kubectl_manifest.stage2]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}

