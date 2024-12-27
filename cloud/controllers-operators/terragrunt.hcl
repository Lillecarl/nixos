include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//${path_relative_to_include("root")}"
}

dependency "paths-creds" {
  config_path = "../paths-creds"
}

inputs = {
  CF_DNS_TOKEN = get_env("CF_DNS_TOKEN")
  paths        = dependency.paths-creds.outputs.paths
}
