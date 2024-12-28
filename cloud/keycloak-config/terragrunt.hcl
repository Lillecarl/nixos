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
    "../keycloak-deploy"
  ]
}
inputs = {
  keycloak_admin_pass = dependency.stage1.outputs.secrets["keycloak-admin"].password
}
