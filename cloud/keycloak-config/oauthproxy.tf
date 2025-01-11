resource "keycloak_openid_client" "oauthproxy" {
  realm_id  = local.realm_id
  client_id = "oauthproxy" # Identifier
  name      = "oauthproxy" # Visual name

  valid_redirect_uris = [
    "https://oauthproxy.lillecarl.com/oauth2/callback",
  ]

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  service_accounts_enabled     = false
  access_type                  = "CONFIDENTIAL"
}
resource "keycloak_openid_group_membership_protocol_mapper" "oauthproxy" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.oauthproxy.id
  name      = "Group Membership"

  claim_name = "groups"
}
resource "keycloak_openid_audience_protocol_mapper" "oauthproxy" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.oauthproxy.id
  name      = "Audience"

  included_client_audience = "oauthproxy" # client name
}
output "oauthproxy_client_secret" {
  value     = keycloak_openid_client.oauthproxy.client_secret
  sensitive = true
}

