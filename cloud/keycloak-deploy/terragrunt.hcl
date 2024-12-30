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
dependencies {
  paths = [
    "../cnpg"
  ]
}
inputs = {
  keycloak_db_pass    = dependency.pg-cluster-config.outputs.secrets["keycloak"].result
  keycloak_admin_pass = dependency.stage1.outputs.secrets["keycloak-admin"].password
  paths               = dependency.stage1.outputs.paths
  deploy              = feature.deploy.value
  k8s_force           = false
}
