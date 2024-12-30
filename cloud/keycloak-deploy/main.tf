variable "keycloak_db_pass" {}
variable "keycloak_admin_pass" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
}
data "kustomization_overlay" "this" {
  namespace = "keycloak"
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  secret_generator {
    name      = "cluster-keycloak"
    namespace = "keycloak"
    type      = "Opaque"
    literals = [
      "host=cluster-rw.pg-cluster.svc.cluster.local",
      "port=5432",
      "user=keycloak",
      "pass=${var.keycloak_db_pass}",
      "database=keycloak",
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
replicaCount: 2
tls:
  enabled: true
  existingSecret: keycloak.lillecarl.com-tls
  usePem: true
production: true
postgresql:
  enabled: false
auth:
  adminUser: superadmin
  adminPassword: ${var.keycloak_admin_pass}
ingress:
  enabled: true
  tls: true
  hostname: keycloak.lillecarl.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
  ingressClassName: nginx
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
  serviceMonitor:
    enabled: true
  prometheusRule:
    enabled: true
startupProbe:
  enabled: true
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 1
  failureThreshold: 60
  successThreshold: 1
YAML
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = local.ids-this-stage0
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "11m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}

