variable "KEYCLOAK_ADMIN_PASS" {}
data "kustomization_overlay" "cnpg-chart" {
  resources = concat(
    tolist(fileset(path.module, "cnpg/*.yaml")),
  )
  secret_generator {
    name      = "cluster-keycloak"
    namespace = "cnpg"
    type      = "Opaque"
    literals = [
      "username=keycloak",
      "password=${var.KEYCLOAK_ADMIN_PASS}",
    ]
    options {
      disable_name_suffix_hash = true
      labels = {
        "cnpg.io/reload" = true
      }
    }
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helm-path
  }
}
resource "kubectl_manifest" "cnpg-chart0" {
  for_each   = data.kustomization_overlay.cnpg-chart.ids_prio[0]
  yaml_body  = data.kustomization_overlay.cnpg-chart.manifests[each.value]
  depends_on = []

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cnpg-chart1" {
  for_each   = data.kustomization_overlay.cnpg-chart.ids_prio[1]
  yaml_body  = data.kustomization_overlay.cnpg-chart.manifests[each.value]
  depends_on = [kubectl_manifest.cnpg-chart0]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "cnpg-chart2" {
  for_each   = data.kustomization_overlay.cnpg-chart.ids_prio[2]
  yaml_body  = data.kustomization_overlay.cnpg-chart.manifests[each.value]
  depends_on = [kubectl_manifest.cnpg-chart1]

  force_conflicts   = local.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
