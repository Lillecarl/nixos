data "kustomization_overlay" "kube-prometheus-stack-chart" {
  helm_charts {
    name          = "kube-prometheus-stack"
    namespace     = "prometheus"
    repo          = "https://prometheus-community.github.io/helm-charts"
    release_name  = "kube-prometheus-stack"
    version       = "67.4.0"
    include_crds  = true
    values_inline = <<YAML
grafana:
  adminPassword: "${local.keycloak_password_raw}"
  persistence:
    enabled: true
    size: 2Gi
  ingress:
    enabled: true
    ingressClassName: traefik
    hosts: [ "grafana.lillecarl.com" ]
    tls: [{
      hosts: [ "grafana.lillecarl.com" ]
    }]
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-staging
YAML
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helm_path
  }
}
resource "kubectl_manifest" "kube-prometheus-stack-chart0" {
  for_each          = data.kustomization_overlay.kube-prometheus-stack-chart.ids_prio[0]
  yaml_body         = data.kustomization_overlay.kube-prometheus-stack-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on = [
    kubectl_manifest.cloudflare-dns-token,
    kubectl_manifest.cert-manager_clusterissuer,
  ]
}
resource "kubectl_manifest" "kube-prometheus-stack-chart1" {
  for_each          = data.kustomization_overlay.kube-prometheus-stack-chart.ids_prio[1]
  yaml_body         = data.kustomization_overlay.kube-prometheus-stack-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.kube-prometheus-stack-chart0]
}
resource "kubectl_manifest" "kube-prometheus-stack-chart2" {
  for_each          = data.kustomization_overlay.kube-prometheus-stack-chart.ids_prio[2]
  yaml_body         = data.kustomization_overlay.kube-prometheus-stack-chart.manifests[each.value]
  server_side_apply = true
  wait              = true
  depends_on        = [kubectl_manifest.kube-prometheus-stack-chart1]
}
