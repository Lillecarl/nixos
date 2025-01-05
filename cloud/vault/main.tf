variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "VAULT_UNSEAL_TOKEN" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  namespace        = "vault"
  excludedIDs      = ["_/Pod/vault/vault-server-test"]
  ids-chart-stage0 = data.kustomization_overlay.chart.ids_prio[0]
  ids-chart-stage1 = var.deploy ? toset([for id in data.kustomization_overlay.chart.ids_prio[1] : id if !contains(local.excludedIDs, id)]) : []
  ids-chart-stage2 = var.deploy ? data.kustomization_overlay.chart.ids_prio[2] : []
  helm_values = {
    global = {
      enabled    = true
      tlsDisable = true
    }
    injector = { enabled = false }
    server = {
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        annotations      = { "cert-manager.io/cluster-issuer" = "letsencrypt-staging" }
        hosts = [{
          host  = "vault.lillecarl.com"
          paths = ["/"]
        }]
        tls = [{
          hosts      = ["vault.lillecarl.com"]
          secretName = "vault-tls"
        }]
      }
      dataStorage = { enabled = false }
      volumes = [{
        name   = "cert"
        secret = { secretName = "vault-tls" }
      }]
      volumeMounts = [{
        mountPath = "/tls"
        name      = "cert"
        readOnly  = true
      }]
      extraEnvironmentVars = {
        VAULT_LOG_LEVEL = "debug"
      }
      extraSecretEnvironmentVars = [
        {
          envName    = "AWS_ACCESS_KEY_ID"
          secretName = "vault-s3"
          secretKey  = "AWS_ACCESS_KEY_ID"
        },
        {
          envName    = "AWS_SECRET_ACCESS_KEY"
          secretName = "vault-s3"
          secretKey  = "AWS_SECRET_ACCESS_KEY"
        },
        {
          envName    = "VAULT_UNSEAL_TOKEN"
          secretName = "unsealer"
          secretKey  = "VAULT_UNSEAL_TOKEN"
        },
      ]
      standalone = {
        enabled = true
        config  = <<HCL
ui = true
api_addr = "https://vault.lillecarl.com"
storage "s3" {
  bucket = "postspace-vault"
  endpoint = "https://5456ceefee94cfc7fa487e309956d7a2.eu.r2.cloudflarestorage.com"
}
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1
  tls_cert_file = "/tls/tls.crt"
  tls_key_file  = "/tls/tls.key"
}
HCL
      }
    }
  }
}
data "kustomization_overlay" "chart" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = local.namespace
  secret_generator {
    name      = "vault-s3"
    namespace = local.namespace
    type      = "Opaque"
    literals = [
      "AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}",
      "AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  secret_generator {
    name      = "unsealer"
    namespace = local.namespace
    type      = "Opaque"
    literals = [
      "VAULT_UNSEAL_TOKEN=${var.VAULT_UNSEAL_TOKEN}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  patches {
    patch = <<YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vault
  namespace: vault
spec:
  template:
    spec:
      containers:
      - name: vault
        lifecycle:
          postStart:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - "while ! vault operator unseal $VAULT_UNSEAL_TOKEN; do echo trying to unlock vault; sleep 5; done"
YAML
  }
  helm_charts {
    name          = "vault"
    release_name  = "vault"
    namespace     = local.namespace
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  helm_globals {
    chart_home = var.paths.charts
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
