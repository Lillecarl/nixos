variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "CF_DNS_TOKEN" {}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  secret_generator {
    name      = "cloudflare-api-token-secret"
    namespace = "external-dns"
    type      = "Opaque"
    literals = [
      "cloudflare_api_token=${var.CF_DNS_TOKEN}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "external-dns"
    namespace     = "external-dns"
    repo          = "oci://registry-1.docker.io/bitnamicharts/"
    release_name  = "external-dns"
    version       = "8.7.1"
    include_crds  = true
    values_inline = <<YAML
crd:
  create: true
metrics:
  enabled: true
provider: cloudflare
cloudflare:
  secretName: cloudflare-api-token-secret
  proxied: false
YAML
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
