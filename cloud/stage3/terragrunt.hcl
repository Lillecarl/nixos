include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//modules/keycloak-config"
}

dependency "stage1" {
  config_path = "../stage1"
}
dependencies {
  paths = [
    "../stage2"
  ]
}

inputs = {
  keycloak_admin_pass = dependency.stage1.outputs.secrets["keycloak-admin"].password
}
