resource "keycloak_openid_client" "grafana" {
  realm_id  = local.realm_id
  client_id = "grafana" # Identifier
  name      = "Grafana" # Visual name

  valid_redirect_uris = [
    "https://grafana.lillecarl.com/login/generic_oauth",
  ]
  base_url    = "https://grafana.lillecarl.com"
  root_url    = "https://grafana.lillecarl.com"
  admin_url   = "https://grafana.lillecarl.com"
  web_origins = ["https://grafana.lillecarl.com"]

  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = false
  access_type                  = "CONFIDENTIAL"
}
resource "keycloak_openid_group_membership_protocol_mapper" "grafana" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.grafana.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}
resource "keycloak_openid_user_realm_role_protocol_mapper" "grafana" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.grafana.id
  name      = "user-realm-role-mapper"

  claim_name  = "roles"
  multivalued = true
}
output "grafana_client_secret" {
  value     = keycloak_openid_client.grafana.client_secret
  sensitive = true
}
