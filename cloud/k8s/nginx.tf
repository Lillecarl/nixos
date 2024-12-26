data "kustomization_overlay" "nginx-chart" {
  namespace = "nginx"
  resources = concat(
    [local.nginx-bundle],
    tolist(fileset(path.module, "nginx/*.yaml")),
  )
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helm-path
  }
}
resource "kubectl_manifest" "nginx-chart0" {
  for_each   = data.kustomization_overlay.nginx-chart.ids_prio[0]
  yaml_body  = data.kustomization_overlay.nginx-chart.manifests[each.value]
  depends_on = []

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "nginx-chart1" {
  for_each   = data.kustomization_overlay.nginx-chart.ids_prio[1]
  yaml_body  = data.kustomization_overlay.nginx-chart.manifests[each.value]
  depends_on = [kubectl_manifest.nginx-chart0]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "nginx-chart2" {
  for_each   = data.kustomization_overlay.nginx-chart.ids_prio[2]
  yaml_body  = data.kustomization_overlay.nginx-chart.manifests[each.value]
  depends_on = [kubectl_manifest.nginx-chart1]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
