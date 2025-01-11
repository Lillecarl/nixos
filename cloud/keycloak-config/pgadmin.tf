resource "keycloak_openid_client" "pgadmin" {
  realm_id  = local.realm_id
  client_id = "pgadmin" # Identifier
  name      = "pgAdmin" # Visual name

  valid_redirect_uris = [
    "https://pgadmin.lillecarl.com/oauth2/authorize",
  ]

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  service_accounts_enabled     = false
  access_type                  = "CONFIDENTIAL"
}
output "pgadmin_client_secret" {
  value     = keycloak_openid_client.pgadmin.client_secret
  sensitive = true
}

