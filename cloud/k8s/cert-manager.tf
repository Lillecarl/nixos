variable "CF_DNS_TOKEN" {}
data "kustomization_overlay" "cert_manager" {
  resources = concat(
    [local.cert_manager-bundle],
    tolist(fileset(path.module, "cert-manager/*.yaml")),
  )
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
    helm_path       = local.helm-path
  }
}
resource "kubectl_manifest" "cert_manager0" {
  for_each   = data.kustomization_overlay.cert_manager.ids_prio[0]
  yaml_body  = data.kustomization_overlay.cert_manager.manifests[each.value]
  depends_on = []

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cert_manager1" {
  for_each   = data.kustomization_overlay.cert_manager.ids_prio[1]
  yaml_body  = data.kustomization_overlay.cert_manager.manifests[each.value]
  depends_on = [kubectl_manifest.cert_manager0]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cert_manager2" {
  for_each   = data.kustomization_overlay.cert_manager.ids_prio[2]
  yaml_body  = data.kustomization_overlay.cert_manager.manifests[each.value]
  depends_on = [kubectl_manifest.cert_manager1]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
