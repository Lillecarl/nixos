variable "dbinfo" { type = map(string) }
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  helm_values = {
    config = {
      plugins = {
        managesieve = {
          enabled = true
        }
      }
    }
    deployment = { replicas = 1 }
    ingress = {
      enabled = true
      host    = "roundcube.lillecarl.com"
      additionalAnnotations = {
        "cert-manager.io/cluster-issuer" = "letsencrypt-staging"
        # "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }
    }
    externalDatabase = {
      type     = "pgsql"
      host     = var.dbinfo.host
      name     = var.dbinfo.name
      user     = var.dbinfo.user
      password = "kustomizeit"
    }
    imap = { host = "imap.migadu.com" }
    smtp = { host = "smtp.migadu.com" }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "roundcube"
  secret_generator {
    name      = "roundcube-overwrite"
    namespace = "roundcube"
    type      = "Opaque"
    literals = [
      "dbUsername=${var.dbinfo.user}",
      "dbPassword=${var.dbinfo.pass}",
      "desKey=4m59VrIspgZoGOMYn3FtMIdtSNzzwhzHqBrFaQ4srY3LK7FFH9elv4bRV3HFE703",
      "smtpUsername=%u",
      "smtpPassword=%p",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  helm_charts {
    name          = "roundcube"
    release_name  = "roundcube"
    namespace     = "roundcube"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  patches {
    patch = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: roundcube
spec:
  template:
    spec:
      containers:
      - name: roundcubemail
        env:
        - name: ROUNDCUBEMAIL_SMTP_USER
          valueFrom:
            secretKeyRef:
              key: smtpUsername
              name: roundcube-overwrite
        - name: ROUNDCUBEMAIL_SMTP_PASS
          valueFrom:
            secretKeyRef:
              key: smtpPassword
              name: roundcube-overwrite
        - name: ROUNDCUBEMAIL_DES_KEY
          valueFrom:
            secretKeyRef:
              key: desKey
              name: roundcube-overwrite
        - name: ROUNDCUBEMAIL_DB_USER
          valueFrom:
            secretKeyRef:
              key: dbUsername
              name: roundcube-overwrite
        - name: ROUNDCUBEMAIL_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: dbPassword
              name: roundcube-overwrite
YAML
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
