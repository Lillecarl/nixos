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
dependencies {
  paths = [
    "../grafana-deploy"
  ]
}
inputs = {
  grafana_admin_pass    = dependency.stage1.outputs.secrets["grafana-admin"].password
  grafana_client_secret = dependency.keycloak.outputs.grafana_client_secret
}
