include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."
}

inputs = {
  secrets = [
    "keycloak-db",
    "keycloak-admin",
    "registry",
  ]
}
