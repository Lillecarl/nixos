include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//${path_relative_to_include("root")}"
}

dependency "paths-creds" {
  config_path = "../paths-creds"
}
dependency "pg-cluster" {
  config_path = "../pg-cluster"
}

inputs = {
  keycloak_db_pass    = dependency.paths-creds.outputs.secrets["keycloak-db"]
  keycloak_admin_pass = dependency.paths-creds.outputs.secrets["keycloak-admin"]
}
