include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//modules/pg-cluster"
}

dependency "paths-creds" {
  config_path = "../paths-creds"
}

inputs = {
  stage0           = true
  stage1           = true
  stage2           = true
  paths            = dependency.paths-creds.outputs.paths
  k8s_force        = false
  keycloak_db_pass = dependency.paths-creds.outputs.secrets["keycloak-db"]
}
