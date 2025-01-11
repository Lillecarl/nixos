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
resource "keycloak_openid_group_membership_protocol_mapper" "kubernetes" {
  realm_id  = local.realm_id
  client_id = keycloak_openid_client.kubernetes.id
  name      = "Group Membership"

  claim_name = "groups"
  full_path  = false
}
