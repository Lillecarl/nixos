include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."

  before_hook "terranix" {
    commands = [
      "apply",
      "plan",
      "destroy",
    ]
    execute = [
      "sh", "-c", "terranix ${get_parent_terragrunt_dir()}/config.nix > ${get_working_dir()}/config.tf.json"
    ]
    run_on_error = false
  }
}

inputs = {
  secrets = [
    "keycloak-db",
    "keycloak-admin",
    "registry",
  ]
}
