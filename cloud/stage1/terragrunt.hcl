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
      "sh", "-c", "terranix ${get_working_dir()}/config.nix > ${get_working_dir()}/config_tf_json && mv ${get_working_dir()}/config_tf_json ${get_working_dir()}/config.tf.json"
    ]
    run_on_error = false
  }
}

inputs = {
  secrets = [
    "grafana-admin",
    "keycloak-admin",
    "pgadmin-admin",
    "postgres-admin",
    "registry",
    "valkey",
  ]
}
