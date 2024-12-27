include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//${path_relative_to_include("root")}"
}

dependency "stage1" {
  config_path = "../stage1"
}

inputs = {
  CF_DNS_TOKEN        = get_env("CF_DNS_TOKEN")
  keycloak_db_pass    = dependency.stage1.outputs.secrets["keycloak-db"].password
  keycloak_admin_pass = dependency.stage1.outputs.secrets["keycloak-admin"].password
  registry_secret     = dependency.stage1.outputs.secrets["registry"]
}
