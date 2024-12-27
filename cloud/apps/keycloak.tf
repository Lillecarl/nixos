variable "keycloak_db_pass" {}
variable "keycloak_admin_pass" {}
module "keycloak" {
  source              = "../modules/keycloak"
  paths               = local.paths
  stage0              = false
  stage1              = true
  stage2              = true
  k8s_force           = false
  keycloak_db_pass    = var.keycloak_db_pass
  keycloak_admin_pass = var.keycloak_admin_pass
}
