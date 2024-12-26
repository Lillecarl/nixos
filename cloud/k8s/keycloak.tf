data "kustomization_overlay" "keycloak-chart" {
  namespace = "keycloak"
  resources = concat(
    tolist(fileset(path.module, "keycloak/*.yaml")),
  )
  secret_generator {
    name      = "cluster-keycloak"
    namespace = "keycloak"
    type      = "Opaque"
    literals = [
      "host=${base64encode("cluster-rw.cnpg.svc.cluster.local")}",
      "port=${base64encode("5432")}",
      "user=${local.cnpg-vars.keycloak_username}",
      "pass=${local.cnpg-vars.keycloak_password}",
      "database=${base64encode("keycloak")}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "keycloak"
    namespace     = "keycloak"
    repo          = "oci://registry-1.docker.io/bitnamicharts/"
    release_name  = "keycloak"
    version       = "24.3.1"
    include_crds  = true
    values_inline = <<YAML
postgresql:
  enabled: false
auth:
  adminUser: carl
  adminPassword: carl
ingress:
  enabled: true
  tls: true
  hostname: keycloak.lillecarl.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
externalDatabase:
  existingSecret: "cluster-keycloak"
  existingSecretHostKey: "host"
  existingSecretPortKey: "port"
  existingSecretUserKey: "user"
  existingSecretPasswordKey: "pass"
  existingSecretDatabaseKey: "database"
  annotations: {}
metrics:
  enabled: true
  # serviceMonitor:
  #   enabled: true
  # prometheusRule:
  #   enabled: true
YAML
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helm_path
  }
}
resource "kubectl_manifest" "keycloak-chart0" {
  for_each   = data.kustomization_overlay.keycloak-chart.ids_prio[0]
  yaml_body  = data.kustomization_overlay.keycloak-chart.manifests[each.value]
  depends_on = [kubectl_manifest.cnpg_resource]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "keycloak-chart1" {
  for_each   = data.kustomization_overlay.keycloak-chart.ids_prio[1]
  yaml_body  = data.kustomization_overlay.keycloak-chart.manifests[each.value]
  depends_on = [kubectl_manifest.keycloak-chart0]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "keycloak-chart2" {
  for_each   = data.kustomization_overlay.keycloak-chart.ids_prio[2]
  yaml_body  = data.kustomization_overlay.keycloak-chart.manifests[each.value]
  depends_on = [kubectl_manifest.keycloak-chart1]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
