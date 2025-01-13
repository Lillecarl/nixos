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
  grafana-admin-pass    = dependency.stage1.outputs.secrets["grafana-admin"].password
  grafana-client-secret = dependency.keycloak.outputs.grafana_client_secret
  paths                 = dependency.stage1.outputs.paths
  deploy                = feature.deploy.value
  k8s_force             = true
}
