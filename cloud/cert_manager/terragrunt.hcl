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
    "../prometheus" # Monitoring CRDs
  ]
}
inputs = {
  CF_DNS_TOKEN = get_env("CF_DNS_TOKEN")
  paths        = dependency.stage1.outputs.paths
  deploy       = feature.deploy.value
  k8s_force    = false
}
