resource "grafana_sso_settings" "github_sso_settings" {
  provider_name = "generic_oauth"
  oauth2_settings {
    name                       = "Keycloak"
    allow_sign_up              = true
    auto_login                 = true
    client_id                  = "grafana"
    client_secret              = local.rs.keycloak-config.grafana_client_secret
    scopes                     = "openid email profile roles"
    auth_url                   = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/auth"
    token_url                  = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/token"
    api_url                    = "https://keycloak.lillecarl.com/realms/master/protocol/openid-connect/userinfo"
    email_attribute_path       = "email"
    groups_attribute_path      = "groups"
    login_attribute_path       = "username"
    name_attribute_path        = "full_name"
    role_attribute_path        = "contains(realm_access.roles[*], 'grafana-admin') && 'GrafanaAdmin' || contains(realm_access.roles[*], 'admin') && 'Admin' || contains(realm_access.roles[*], 'editor') && 'Editor' || 'Viewer'"
    allow_assign_grafana_admin = true
  }
}
