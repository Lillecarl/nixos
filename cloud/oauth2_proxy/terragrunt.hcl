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
  client_secret = dependency.keycloak.outputs.oauthproxy_client_secret
  cookie_secret = dependency.stage1.outputs.oauthproxy_cookie_secret
  paths         = dependency.stage1.outputs.paths
  deploy        = feature.deploy.value
  k8s_force     = false
}
