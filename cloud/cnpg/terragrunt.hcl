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
inputs = {
  R2_ACCESS_KEY_ID     = get_env("CNPG_R2_ACCESS_SECRET_KEY")
  R2_ACCESS_SECRET_KEY = get_env("CNPG_R2_ACCESS_SECRET_KEY")
  keycloak_db_pass     = dependency.stage1.outputs.secrets["keycloak-db"].password
  pgadmin_db_pass      = dependency.stage1.outputs.secrets["pgadmin-db"].password
  paths                = dependency.stage1.outputs.paths
  deploy               = feature.deploy.value
  k8s_force            = false
}
