locals {
  registry-url = "registry.lillecarl.com"
}
resource "keycloak_openid_client" "registry" {
  realm_id  = local.realm_id
  client_id = "registry" # Identifier
  name      = "registry" # Visual name

  valid_redirect_uris = [
    "https://${local.registry-url}/login/generic_oauth",
    "*",
  ]
  base_url    = "https://${local.registry-url}"
  root_url    = "https://${local.registry-url}"
  admin_url   = "https://${local.registry-url}"
  web_origins = ["https://${local.registry-url}"]

  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = false
  access_type                  = "CONFIDENTIAL"
}
resource "keycloak_openid_group_membership_protocol_mapper" "registry" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.registry.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}
output "registry_client_secret" {
  value     = keycloak_openid_client.registry.client_secret
  sensitive = true
}
