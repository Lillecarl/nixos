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
    "../cert_manager"
  ]
}
inputs = {
  BITWARDEN_MACHINE_KEY = get_env("BITWARDEN_MACHINE_KEY")
  paths                 = dependency.stage1.outputs.paths
  deploy                = feature.deploy.value
  k8s_force             = false
}
