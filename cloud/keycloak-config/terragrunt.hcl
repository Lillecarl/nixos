include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//modules/keycloak-config"
}

dependency "paths-creds" {
  config_path = "../paths-creds"
}
dependencies {
  paths = [
    "../apps"
  ]
}

inputs = {
  keycloak_admin_pass = dependency.paths-creds.outputs.secrets["keycloak-admin"]
}
