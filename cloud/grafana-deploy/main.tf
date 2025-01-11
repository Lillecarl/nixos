variable "grafana-admin-pass" {}
variable "grafana-client-secret" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  helm_values = {
    assertNoLeakedSecrets = false
    admin = {
      existingSecret = "admin"
      userKey        = "username"
      passwordKey    = "password"
    }
    ingress = {
      enabled          = true
      ingressClassName = "nginx"
      annotations      = { "cert-manager.io/cluster-issuer" = "letsencrypt-staging" }
      hosts            = ["grafana.lillecarl.com"]
      tls = [{
        hosts      = ["grafana.lillecarl.com"]
        secretName = "tls"
      }]
    }
    persistence = {
      enabled          = true
      storageClassName = "local-path"
      size             = "1Gi"
    }
    "grafana.ini" = {
      analytics = { check_for_updates = false }
      server = {
        root_url = "https://grafana.lillecarl.com"
      }
      # "auth.generic_oauth" = {
      #   enabled                    = true
      #   name                       = "Keycloak"
      #   allow_sign_up              = true
      #   auto_login                 = true
      #   client_id                  = "grafana"
      #   client_secret              = var.grafana-client-secret
      #   scopes                     = "openid email profile roles"
      #   auth_url                   = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/auth"
      #   token_url                  = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/token"
      #   api_url                    = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/userinfo"
      #   email_attribute_path       = "email"
      #   groups_attribute_path      = "groups"
      #   login_attribute_path       = "username"
      #   name_attribute_path        = "full_name"
      #   role_attribute_path        = "contains(roles[*], 'grafana-admin') && 'GrafanaAdmin' || contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'"
      #   allow_assign_grafana_admin = true
      #   # use_refresh_token          = true
      # }
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "grafana"
  helm_charts {
    name          = "grafana"
    release_name  = "grafana"
    namespace     = "grafana"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  secret_generator {
    name = "admin"
    type = "Opaque"
    literals = [
      "username=admin",
      "password=${var.grafana-admin-pass}",
    ]
    options { disable_name_suffix_hash = true }
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
