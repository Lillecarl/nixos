variable "grafana_admin_pass" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
data "kustomization_overlay" "bundle" {
  namespace = "monitoring"
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  helm_charts {
    name          = "kube-prometheus-stack"
    namespace     = "kube-prometheus-stack"
    repo          = "https://prometheus-community.github.io/helm-charts"
    release_name  = "kube-prometheus-stack"
    include_crds  = true
    values_inline = <<YAML
grafana:
  adminPassword: "${var.grafana_admin_pass}"
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-staging
    hosts:
      - grafana.lillecarl.com
    tls:
      - secretName: grafana-lillecarl-com-tls
        hosts:
        - grafana.lillecarl.com
YAML
  }
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
  depends_on = [kubectl_manifest.bundle-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
