locals {
  realm_id = data.keycloak_realm.realm.id
}
data "http" "keycloak" {
  url = "https://keycloak.lillecarl.com"
  retry {
    attempts     = 30
    max_delay_ms = 10000
    min_delay_ms = 10000
  }
}
data "keycloak_realm" "realm" {
  realm = "master"
  depends_on = [
    data.http.keycloak
  ]
}
data "keycloak_role" "admin" {
  realm_id = data.keycloak_realm.realm.id
  name     = "admin"
}
resource "keycloak_group" "kubernetes-admin" {
  realm_id = local.realm_id
  name     = "kubernetes-admin"
}
resource "keycloak_user" "kubernetes-admin" {
  realm_id       = local.realm_id
  email          = "kubernetes-admin@lillecarl.com"
  email_verified = true
  username       = "kubernetes-admin"
  initial_password {
    value     = var.keycloak_admin_pass
    temporary = false
  }
}
resource "keycloak_user_groups" "kubernetes-admin" {
  realm_id = local.realm_id
  user_id  = keycloak_user.kubernetes-admin.id

  group_ids = [
    keycloak_group.kubernetes-admin.id
  ]
}
resource "keycloak_group_roles" "kubernetes-admin" {
  realm_id = data.keycloak_realm.realm.id
  group_id = keycloak_group.kubernetes-admin.id

  role_ids = [
    data.keycloak_role.admin.id
  ]
}
resource "keycloak_group" "kubernetes-viewer" {
  realm_id = local.realm_id
  name     = "kubernetes-viewer"
}
resource "keycloak_user" "kubernetes-viewer" {
  realm_id       = local.realm_id
  email_verified = true
  username       = "kubernetes-viewer"
}
resource "keycloak_user_groups" "kubernetes-viewer" {
  realm_id = local.realm_id
  user_id  = keycloak_user.kubernetes-viewer.id

  group_ids = [
    keycloak_group.kubernetes-viewer.id
  ]
}
resource "keycloak_openid_client" "kubernetes" {
  realm_id  = local.realm_id
  client_id = "kubernetes" # Identifier
  name      = "Kubernetes" # Visual name

  valid_redirect_uris = [
    "http://localhost:8000", # kubelogin port
  ]

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  service_accounts_enabled     = false
  access_type                  = "PUBLIC"
}
resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.kubernetes.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}

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
