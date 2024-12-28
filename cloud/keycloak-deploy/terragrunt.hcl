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
dependencies {
  paths = [
    "../cnpg"
  ]
}
inputs = {
  keycloak_db_pass    = dependency.stage1.outputs.secrets["keycloak-db"].password
  keycloak_admin_pass = dependency.stage1.outputs.secrets["keycloak-admin"].password
  paths               = dependency.stage1.outputs.paths
  deploy              = feature.deploy.value
  k8s_force           = false
}
