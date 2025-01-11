variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  helm_values = {
    nextcloud = {
      host = "nextcloud.lillecarl.com"
      existingSecret = {
        secretName      = "admin"
        usernameKey     = "nextuser"
        passwordKey     = "nextpass"
        smtpUsernameKey = "smtpuser"
        smtpPasswordKey = "smtppass"
        smtpHostKey     = "smtphost"
        tokenKey        = "token"
      }
      mail = {
        enabled = false # todo: enable
      }
      objectStore = { s3 = {
        enabled        = true
        existingSecret = "s3" # secretName
        secretKeys = {
          host      = ""
          accessKey = ""
          secretKey = ""
          bucket    = ""
        }
      } }
      persistence = {
        enabled      = true
        storageClass = "hcloud-volumes"
        size         = "10Gi"
      }
    }
    ingress = {
      enabled   = true
      className = "nginx"
      annotations = {
        # cert-manager
      }
      tls = [{

      }]
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  secret_generator {
    name      = "cloudflare-api-token-secret"
    namespace = "external-dns"
    type      = "Opaque"
    literals = [
      "cloudflare_api_token=${var.CF_DNS_TOKEN}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "external-dns"
    release_name  = "external-dns"
    namespace     = "external-dns"
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
  timeouts { create = "1m" }
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
