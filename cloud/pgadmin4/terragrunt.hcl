terraform {
  source = "."
}
include "root" {
  path = find_in_parent_folders("root.hcl")
}
feature "deploy" {
  default = true
}
dependency "stage1" {
  config_path = "../stage1"
}
dependency "pg-cluster-config" {
  config_path = "../pg-cluster-config"
}
dependency "keycloak" {
  config_path = "../keycloak-config"
}
inputs = {
  pgadmin_client_secret  = dependency.keycloak.outputs.pgadmin_client_secret
  pgadmin_admin_email    = "username@domain.tld"
  pgadmin_admin_password = dependency.stage1.outputs.secrets["pgadmin-admin"].password
  pgadmin_db_username    = "pgadmin"
  pgadmin_db_password    = dependency.pg-cluster-config.outputs.secrets["pgadmin"].result
  paths                  = dependency.stage1.outputs.paths
  deploy                 = feature.deploy.value
  k8s_force              = false
}
