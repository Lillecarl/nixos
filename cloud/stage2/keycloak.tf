module "keycloak" {
  count               = 1
  source              = "../modules/keycloak-deploy"
  paths               = local.paths
  k8s_force           = false
  keycloak_db_pass    = var.keycloak_db_pass
  keycloak_admin_pass = var.keycloak_admin_pass
  depends_on = [
    module.cnpg
  ]
}
