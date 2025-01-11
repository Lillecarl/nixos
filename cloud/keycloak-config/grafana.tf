locals {
  grafana-url = "grafana.lillecarl.com"
}
resource "keycloak_openid_client" "grafana" {
  realm_id  = local.realm_id
  client_id = "grafana" # Identifier
  name      = "Grafana" # Visual name

  valid_redirect_uris = [
    "https://${local.grafana-url}/login/generic_oauth",
  ]
  base_url    = "https://${local.grafana-url}"
  root_url    = "https://${local.grafana-url}"
  admin_url   = "https://${local.grafana-url}"
  web_origins = ["https://${local.grafana-url}"]

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
output "grafana_client_secret" {
  value     = keycloak_openid_client.grafana.client_secret
  sensitive = true
}
