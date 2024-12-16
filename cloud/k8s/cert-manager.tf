locals {
  cm_path = "${local.kust_path}/cm"
}
variable "CF_DNS_TOKEN" {}

data "http" "cm-manifest" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml"
}

resource "local_file" "cm-release" {
  content  = data.http.cm-manifest.response_body
  filename = "${local.cm_path}/operator.yaml"
}

resource "local_file" "cm-extras" {
  content  = <<YAML
---
YAML
  filename = "${local.cm_path}/extras.yaml"
}

data "kustomization_overlay" "cm-manifests" {
  resources = [
    "${local_file.cm-release.filename}",
    "${local_file.cm-extras.filename}",
  ]
} 

resource "kubectl_manifest" "cm0" {
  for_each = data.kustomization_overlay.cm-manifests.ids_prio[0]

  yaml_body = data.kustomization_overlay.cm-manifests.manifests[each.value]
  server_side_apply = true
}

resource "kubectl_manifest" "cm1" {
  for_each = data.kustomization_overlay.cm-manifests.ids_prio[1]

  yaml_body = data.kustomization_overlay.cm-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.cm0]
}

resource "kubectl_manifest" "cm2" {
  for_each = data.kustomization_overlay.cm-manifests.ids_prio[2]

  yaml_body = data.kustomization_overlay.cm-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.cm1]
}

resource "kubectl_manifest" "cm-cf-secret" {
    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
type: Opaque
stringData:
  api-token: ${var.CF_DNS_TOKEN}
YAML
  depends_on = [
    kubectl_manifest.cm0,
    kubectl_manifest.cm1,
    kubectl_manifest.cm2,
  ]
}

resource "kubectl_manifest" "cm-cf-issuer" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: le@lillecarl.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging-account-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
YAML
  depends_on = [
    kubectl_manifest.cm-cf-secret,
  ]
}

resource "kubectl_manifest" "cm-cert-lillecarl-com" {
  count = 1
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: lillecarl-com
  namespace: default
spec:
  secretName: lillecarl-com-tls

  additionalOutputFormats:
  - type: CombinedPEM
  - type: DER
  dnsNames:
    - lillecarl.com
    - www.lillecarl.com

  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
YAML
  depends_on = [
    kubectl_manifest.cm-cf-issuer,
  ]
}
