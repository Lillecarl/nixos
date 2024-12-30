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
dependency "keycloak" {
  config_path = "../keycloak-config"
}
inputs = {
  pgadmin_client_secret = dependency.keycloak.outputs.pgadmin_client_secret
  paths                 = dependency.stage1.outputs.paths
  deploy                = feature.deploy.value
  k8s_force             = false
}
