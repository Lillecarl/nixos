variable "pgadmin_admin_email" {}
variable "pgadmin_admin_password" {}
variable "pgadmin_db_username" {}
variable "pgadmin_db_password" {}
variable "pgadmin_client_secret" {}
variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-stage1 = var.deploy ? data.kustomization_overlay.this.ids_prio[1] : []
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "pgadmin"
  secret_generator {
    name = "pgadmin-admin"
    type = "Opaque"
    literals = [
      "PGADMIN_SETUP_EMAIL=${var.pgadmin_admin_email}",
      "PGADMIN_SETUP_PASSWORD=${var.pgadmin_admin_password}",
    ]
    options {
      disable_name_suffix_hash = true
      labels = {
        "cnpg.io/reload" = true
      }
    }
  }
  secret_generator {
    name = "pgadmin-db"
    type = "Opaque"
    literals = [
      "PGADMIN_PG_USERNAME=${var.pgadmin_db_username}",
      "PGADMIN_PG_PASSWORD=${var.pgadmin_db_password}",
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
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = local.ids-this-stage0
  yaml_body  = local.manifests_substituted[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = local.manifests_substituted[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = local.manifests_substituted[each.value]
  depends_on = [kubectl_manifest.stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
}
locals {
  manifests_substituted = { for k, v in data.kustomization_overlay.this.manifests : k =>
    provider::string-functions::multi_replace(v, {
      "$OAUTH2_CLIENT_SECRET" = sensitive(var.pgadmin_client_secret),
    })
  }
}
