locals {
  realm_id = data.keycloak_realm.realm.id
}
data "keycloak_realm" "realm" {
  realm = "master"
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
  email_verified = true
  username       = "kubernetes-admin"
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
resource "keycloak_openid_client" "openid_client" {
  realm_id  = local.realm_id
  client_id = "kubernetes"
  name      = "client_kubernetes"

  valid_redirect_uris = [
    "http://localhost:8000",
  ]

  standard_flow_enabled        = true
  direct_access_grants_enabled = false
  service_accounts_enabled     = false
  access_type                  = "PUBLIC"
}
resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.openid_client.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}
