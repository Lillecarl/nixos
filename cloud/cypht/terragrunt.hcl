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
dependency "mariadb" {
  config_path = "../mariadb_deploy"
}
inputs = {
  dbinfo   = dependency.mariadb.outputs.dbinfo["cypht"]
  password = dependency.stage1.outputs.secrets["cypht"].password
  paths    = dependency.stage1.outputs.paths
}
