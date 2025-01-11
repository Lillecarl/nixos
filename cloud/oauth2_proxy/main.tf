variable "client_secret" {}
variable "cookie_secret" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  helm_values = {
    httpScheme = "https"
    config = {
      existingSecret = "secrets"
    }
    extraArgs = {
      provider              = "keycloak-oidc"
      client-secret         = var.client_secret
      tls-cert-file         = "/tls/tls.crt"
      tls-key-file          = "/tls/tls.key"
      reverse-proxy         = false # running behind reverse proxy?
      redirect-url          = "https://oauthproxy.lillecarl.com/oauth2/callback"
      oidc-issuer-url       = "https://keycloak.lillecarl.com/realms/master"
      allowed-group         = "/kubernetes-admin"
      code-challenge-method = "S256"
      upstream              = "https://registry.lillecarl.com"
      # client-id             = "oauthproxy"
      # cookie-secret         = var.cookie_secret
      # cookie-secure         = true
      # http-address          = ":4180"
      # https-address         = ":443"
    }
    extraVolumes = [{
      name   = "tls"
      secret = { secretName = "tls" }
    }]
    extraVolumeMounts = [{
      mountPath = "/tls"
      name      = "tls"
    }]
    service = {
      type        = "LoadBalancer"
      portNumber  = 1443
      appProtocol = "https"
      annotations = {
        "external-dns.alpha.kubernetes.io/hostname"    = "oauthproxy.lillecarl.com"
        "external-dns.alpha.kubernetes.io/target-type" = "A"
      }
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "oauth2-proxy"
  secret_generator {
    name = "secrets"
    type = "Opaque"
    literals = [
      "cookie-secret=${var.cookie_secret}",
      "client-secret=${var.client_secret}",
      "client-id=oauthproxy",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "oauth2-proxy"
    release_name  = "oauth2-proxy"
    namespace     = "oauth2-proxy"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  patches {
    patch = yamlencode({
      apiVersion = "v1"
      kind       = "Service"
      metadata = {
        name      = "oauth2-proxy"
        namespace = "oauth2-proxy"
      }
      spec = {
        loadBalancerClass = "io.cilium/node"
      }
    })
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
