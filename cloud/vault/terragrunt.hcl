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
  AWS_ACCESS_KEY_ID     = get_env("VAULT_AWS_ACCESS_KEY_ID")
  AWS_SECRET_ACCESS_KEY = get_env("VAULT_AWS_SECRET_ACCESS_KEY")
  VAULT_UNSEAL_TOKEN    = get_env("VAULT_UNSEAL_TOKEN")
  paths                 = dependency.stage1.outputs.paths
  deploy                = feature.deploy.value
  k8s_force             = false
}
