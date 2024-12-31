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
  R2_ACCESS_KEY_ID       = get_env("CNPG_R2_ACCESS_KEY_ID")
  R2_ACCESS_SECRET_KEY   = get_env("CNPG_R2_ACCESS_SECRET_KEY")
  postgres-admin_db_pass = dependency.stage1.outputs.secrets["postgres-admin"].password
  paths                  = dependency.stage1.outputs.paths
  deploy                 = feature.deploy.value
  k8s_force              = false
}
