locals {
  postgrest-url = "postgrest.lillecarl.com"
}
data "keycloak_realm_keys" "realm_keys" {
  realm_id   = data.keycloak_realm.realm.id
  algorithms = ["RS256"]
  status     = ["ACTIVE"]
}
output "realm_RS256_public_key" {
  value = data.keycloak_realm_keys.realm_keys.keys[0].public_key
}
data "jwks_from_key" "realm_RS256" {
  key = data.keycloak_realm_keys.realm_keys.keys[0].public_key
}
output "realm_RS256_jwks" {
  value = data.jwks_from_key.realm_RS256.jwks
}
resource "keycloak_openid_client" "postgrest" {
  realm_id  = local.realm_id
  client_id = "postgrest" # Identifier
  name      = "postgrest" # Visual name

  valid_redirect_uris = [
    "https://${local.postgrest-url}/some",
    "https://playground.please-open.it/",
    "*",
  ]
  base_url    = "https://${local.postgrest-url}"
  root_url    = "https://${local.postgrest-url}"
  admin_url   = "https://${local.postgrest-url}"
  web_origins = ["https://${local.postgrest-url}"]

  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = false
  access_type                  = "PUBLIC"
}
resource "keycloak_openid_group_membership_protocol_mapper" "postgrest" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.postgrest.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}
output "postgrest_client_secret" {
  value     = keycloak_openid_client.postgrest.client_secret
  sensitive = true
}

