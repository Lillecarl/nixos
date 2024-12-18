resource "kubectl_manifest" "external-dns-namespace" {
    yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
YAML
}

resource "kubectl_manifest" "cloudflare-dns-token" {
    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-dns-token
  namespace: external-dns
data:
  token: ${base64encode(var.CF_DNS_TOKEN)}
type: Opaque
YAML
  depends_on = [
    kubectl_manifest.external-dns-namespace
  ]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.15.0"

  values = [
    (<<YAML
provider: 
  name: cloudflare
env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        name: cloudflare-dns-token
        key: token
YAML
    )
  ]
  depends_on = [
    kubectl_manifest.cloudflare-dns-token
  ]
}
