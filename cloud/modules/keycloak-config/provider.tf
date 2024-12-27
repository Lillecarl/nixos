variable "keycloak_admin_pass" {}
provider "keycloak" {
  url                      = "https://keycloak.lillecarl.com"
  client_id                = "admin-cli"
  username                 = "superadmin"
  password                 = var.keycloak_admin_pass
  tls_insecure_skip_verify = true
}
