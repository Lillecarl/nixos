variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "CF_DNS_TOKEN" {}
data "kustomization_overlay" "bundle" {
  resources = [var.paths.cert_manager-bundle]
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "bundle-stage0" {
  for_each   = data.kustomization_overlay.bundle.ids_prio[0]
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "bundle-stage1" {
  for_each   = data.kustomization_overlay.bundle.ids_prio[1]
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = [kubectl_manifest.bundle-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "bundle-stage2" {
  for_each   = data.kustomization_overlay.bundle.ids_prio[2]
  yaml_body  = data.kustomization_overlay.bundle.manifests[each.value]
  depends_on = [kubectl_manifest.bundle-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
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
resource "time_sleep" "sixty" {
  depends_on = [kubectl_manifest.bundle-stage2]

  create_duration = "60s"
}
resource "kubectl_manifest" "config-stage0" {
  for_each   = data.kustomization_overlay.config.ids_prio[0]
  yaml_body  = data.kustomization_overlay.config.manifests[each.value]
  depends_on = [time_sleep.sixty]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "config-stage1" {
  for_each   = data.kustomization_overlay.config.ids_prio[1]
  yaml_body  = data.kustomization_overlay.config.manifests[each.value]
  depends_on = [kubectl_manifest.config-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "config-stage2" {
  for_each   = data.kustomization_overlay.config.ids_prio[2]
  yaml_body  = data.kustomization_overlay.config.manifests[each.value]
  depends_on = [kubectl_manifest.config-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}

