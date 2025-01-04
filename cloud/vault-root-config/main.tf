resource "vault_policy" "oidc-admin" {
  name = "oidc-admin"

  policy = <<HCL
path "*" {
  capabilities = ["sudo","read","create","update","delete","list","patch"]
}
HCL
}
resource "vault_identity_group" "oidc-admin" {
  name     = "oidc-admin"
  type     = "internal"
  policies = ["oidc-admin"]
}
resource "vault_identity_entity" "oidc-admin" {
  name     = "oidc-admin"
  policies = ["oidc-admin"]
}
resource "vault_identity_oidc_assignment" "oidc-admin" {
  name = "oidc-admin"
  entity_ids = [
    vault_identity_entity.oidc-admin.id,
  ]
  group_ids = [
    vault_identity_group.oidc-admin.id,
  ]
}
resource "vault_identity_oidc_client" "keycloak" {
  name = "vault"
  redirect_uris = [
    "https://vault.lillecarl.com/ui/vault/auth/oidc/oidc/callback",
  ]
  assignments = [
    vault_identity_oidc_assignment.oidc-admin.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}
