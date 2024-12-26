data "kustomization_overlay" "external-dns-chart" {
  resources = fileset(path.module, "external-dns/*.yaml")
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
    helm_path       = local.helm_path
  }
}
resource "kubectl_manifest" "external-dns-chart0" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[0]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  depends_on        = []
}
resource "kubectl_manifest" "external-dns-chart1" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[1]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.external-dns-chart0]
}
resource "kubectl_manifest" "external-dns-chart2" {
  for_each          = data.kustomization_overlay.external-dns-chart.ids_prio[2]
  yaml_body         = data.kustomization_overlay.external-dns-chart.manifests[each.value]
  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.external-dns-chart1]
}
