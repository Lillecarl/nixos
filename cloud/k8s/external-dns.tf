locals {
  external-dns-namespace = "external-dns"
}
resource "kubectl_manifest" "external-dns-namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: "${local.external-dns-namespace}"
YAML
}
resource "kubectl_manifest" "cloudflare-dns-token" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: cloudflare-dns-token
  namespace: "${local.external-dns-namespace}"
data:
  cloudflare_api_token: ${base64encode(var.CF_DNS_TOKEN)}
YAML
  depends_on = [
    kubectl_manifest.external-dns-namespace
  ]
}
data "kustomization_overlay" "external-dns-chart" {
  helm_charts {
    name          = "external-dns"
    namespace     = local.external-dns-namespace
    repo          = "oci://registry-1.docker.io/bitnamicharts/"
    release_name  = "external-dns"
    version       = "8.7.1"
    include_crds  = true
    values_inline = <<YAML
metrics:
  enabled: true
provider: cloudflare
cloudflare:
  secretName: cloudflare-dns-token
  proxied: false
YAML
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helm_path
  }
}
resource "kubectl_manifest" "external-dns-chart0" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[0]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.cloudflare-dns-token]
}
resource "kubectl_manifest" "external-dns-chart1" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[1]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.external-dns-chart0]
}
resource "kubectl_manifest" "external-dns-chart2" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[2]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.external-dns-chart1]
}
