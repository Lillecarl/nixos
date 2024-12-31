variable "R2_ACCESS_KEY_ID" {}
variable "R2_ACCESS_SECRET_KEY" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-chart-stage0 = data.kustomization_overlay.chart.ids_prio[0]
  ids-chart-stage1 = var.deploy ? data.kustomization_overlay.chart.ids_prio[1] : []
  ids-chart-stage2 = var.deploy ? data.kustomization_overlay.chart.ids_prio[2] : []
}
data "kustomization_overlay" "chart" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "vault"
  helm_charts {
    name          = "vault"
    namespace     = "vault"
    repo          = "https://helm.releases.hashicorp.com"
    release_name  = "vault"
    version       = "0.29.1"
    include_crds  = true
    values_inline = <<YAML
global:
  enabled: true
  tlsDisable: true
injector:
  enabled: "false"
server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-staging
    hosts:
      - host: vault.lillecarl.com
        paths: [ "/" ]
    tls:
      - hosts: [ "vault.lillecarl.com" ]
        secretName: vault-tls
  dataStorage:
    enabled: false
  extraEnvironmentVars:
    VAULT_LOG_LEVEL: "debug"
  standalone:
    enabled: true
    config: |
      storage "s3" {
        bucket = "postspace-vault"
        # region = "us-east-1"
        endpoint = "https://5456ceefee94cfc7fa487e309956d7a2.eu.r2.cloudflarestorage.com"
        access_key = "b15d6068f4fbda3ee57e4d523f200755"
        secret_key = "2267c3458d868682ac65759f37cca0b7fba74731a816ba8eb4b809ad067f1395"
      }
      listener "tcp" {
        address = "0.0.0.0:8200"
        tls_disable = 1
      }
      disable_mlock = true
      ui = true
YAML
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "chart-stage0" {
  for_each   = local.ids-chart-stage0
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "chart-stage1" {
  for_each   = local.ids-chart-stage1
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = [kubectl_manifest.chart-stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "chart-stage2" {
  for_each   = local.ids-chart-stage2
  yaml_body  = data.kustomization_overlay.chart.manifests[each.value]
  depends_on = [kubectl_manifest.chart-stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
