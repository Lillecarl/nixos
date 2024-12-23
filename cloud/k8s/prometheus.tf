resource "helm_release" "kube-prometheus-stack" {
  name             = "kube-prometheus-stack"
  namespace        = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "67.4.0"
  create_namespace = true

  values = [
    (<<YAML
grafana:
  adminPassword: "${local.keycloak_password_raw}"
  persistence:
    enabled: true
    size: 2Gi
  ingress:
    enabled: true
    hosts: [ "grafana.lillecarl.com" ]
    tls: [{
      hosts: [ "grafana.lillecarl.com" ]
    }]
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-staging
YAML
    )
  ]
  depends_on = [
    kubectl_manifest.cloudflare-dns-token
  ]
}
