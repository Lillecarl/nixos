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
dependency "postgres" {
  config_path = "../pg-cluster-config"
}
inputs = {
  dbinfo    = dependency.postgres.outputs.dbinfo["roundcube"]
  paths     = dependency.stage1.outputs.paths
  deploy    = feature.deploy.value
  k8s_force = false
}
