module "cnpg" {
  count            = 1
  source           = "../modules/cnpg"
  paths            = local.paths
  k8s_force        = false
  keycloak_db_pass = var.keycloak_db_pass
}
