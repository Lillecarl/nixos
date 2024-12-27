module "keycloak" {
  source              = "../modules/keycloak-deploy"
  paths               = local.paths
  stage0              = true
  stage1              = false
  stage2              = false
  k8s_force           = false
  keycloak_db_pass    = ""
  keycloak_admin_pass = ""
}
