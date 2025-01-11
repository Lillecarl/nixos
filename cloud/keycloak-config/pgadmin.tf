resource "keycloak_openid_client" "pgadmin" {
  realm_id  = local.realm_id
  client_id = "pgadmin" # Identifier
  name      = "pgAdmin" # Visual name

  valid_redirect_uris = [
    "https://pgadmin.lillecarl.com/oauth2/authorize",
  ]
  base_url    = "https://pgadmin.lillecarl.com"
  root_url    = "https://pgadmin.lillecarl.com"
  admin_url   = "https://pgadmin.lillecarl.com"
  web_origins = ["https://pgadmin.lillecarl.com"]

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  service_accounts_enabled     = false
  access_type                  = "CONFIDENTIAL"
}
output "pgadmin_client_secret" {
  value     = keycloak_openid_client.pgadmin.client_secret
  sensitive = true
}

