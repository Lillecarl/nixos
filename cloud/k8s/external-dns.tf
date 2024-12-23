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

resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = local.external-dns-namespace
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "external-dns"
  version    = "8.7.1"

  values = [
    (<<YAML
metrics:
  enabled: true
provider: cloudflare
cloudflare:
  secretName: cloudflare-dns-token
YAML
    )
  ]
  depends_on = [
    kubectl_manifest.cloudflare-dns-token
  ]
}
