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
dependencies {
  paths = [
    "../cnpg",
  ]
}
inputs = {
  postgres-admin-username = "postgres-admin"
  postgres-admin-password = dependency.stage1.outputs.secrets["postgres-admin"].password
  postgres-admin-hostname = "postgres.lillecarl.com"
  postgres-admin-portnumb = 5432
  stdroles = [
    "pgadmin",
    "keycloak",
  ]
  paths     = dependency.stage1.outputs.paths
  deploy    = feature.deploy.value
  k8s_force = false
}
