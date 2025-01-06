variable "dbinfo" { type = map(string) }
variable "password" {}
variable "paths" { type = map(string) }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = data.kustomization_overlay.this.ids_prio[1]
  ids-this-stage2 = data.kustomization_overlay.this.ids_prio[2]
}
resource "random_password" "admin" {
  length  = 16
  special = false
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "cypht"
  secret_generator {
    name = "login"
    type = "Opaque"
    literals = [
      "user=admin",
      "pass=${var.password}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  secret_generator {
    name = "db"
    type = "Opaque"
    literals = [
      "host=${var.dbinfo.host}",
      "name=${var.dbinfo.name}",
      "user=${var.dbinfo.user}",
      "pass=${var.dbinfo.pass}",
      "port=${var.dbinfo.port}",
    ]
    options {
      disable_name_suffix_hash = true
    }
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

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
