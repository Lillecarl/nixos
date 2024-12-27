module "keycloak" {
  source              = "../modules/keycloak"
  paths               = local.paths
  stage0              = true
  stage1              = false
  stage2              = false
  k8s_force           = false
  keycloak_db_pass    = "" # We're only deploying NS and CRD
  keycloak_admin_pass = "" # We're only deploying NS and CRD
}
