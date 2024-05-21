terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}

provider "keycloak" {
  url       = "https://auth.lillecarl.com"
  username  = "admin"
  password  = "changeme"
  client_id = "admin-cli"
}

#variable "ks_file" {}
#variable "ks_pass" {}
#variable "ts_file" {}
#variable "ts_pass" {}
#variable "pk_pass" {}

locals {
  realm_name = "master"
}

resource "keycloak_realm" "carlistan" {
  realm        = "carlistan"
  display_name = "Carlistan"

  attributes = {
    frontendUrl = "https://bankid.lillecarl.com"
  }
}

resource "keycloak_oidc_identity_provider" "realm_identity_provider" {
  realm             = keycloak_realm.carlistan.id
  alias             = "bankid"
  provider_id       = "bankid"
  authorization_url = "https://appapi2.test.bankid.com/"
  client_id         = "client_id"
  client_secret     = "client_secret"
  token_url         = "token_url"
  sync_mode         = "IMPORT"

  extra_config = {
    bankid_apiurl              = "https://appapi2.test.bankid.com/"
    bankid_keystore_file       = "/nix/store/8v5fmmk300vv6xrb23rbjfypsiacclzv-source/resources/FPTestcert4_20230629.p12"
    bankid_keystore_password   = "qwerty123"
    bankid_privatekey_password = "qwerty123"
    bankid_truststore_file     = "/nix/store/1g3j65zq3qrc0i5s416kyha344hs1fzy-source/resources/truststore.p12"
    bankid_truststore_password = "qwerty123"
    bankid_require_nin         = false
    bankid_show_qr_code        = true
    bankid_save_nin_hash       = false
  }
}

resource "keycloak_openid_client" "account" {
  enabled   = true
  realm_id  = keycloak_realm.carlistan.id
  client_id = "account"

  name        = "$${client_account}"
  access_type = "PUBLIC"

  root_url = "https://bankid.lillecarl.com"
  base_url = "/realms/carlistan/account/"

  use_refresh_tokens = true

  valid_redirect_uris = [
    "/realms/carlistan/account/*"
  ]
}

resource "keycloak_openid_client" "account-console" {
  enabled   = true
  realm_id  = keycloak_realm.carlistan.id
  client_id = "account-console"

  name        = "$${client_account-console}"
  access_type = "PUBLIC"

  root_url = "https://bankid.lillecarl.com"
  base_url = "/realms/carlistan/account/"

  use_refresh_tokens                  = false
  full_scope_allowed                  = false
  backchannel_logout_session_required = false

  valid_redirect_uris = [
    "/realms/carlistan/account/*"
  ]
}

resource "keycloak_openid_client" "security-admin-console" {
  enabled   = true
  realm_id  = keycloak_realm.carlistan.id
  client_id = "security-admin-console"

  name        = "$${client_security-admin-console}"
  access_type = "PUBLIC"

  root_url = "https://bankid.lillecarl.com"
  base_url = "/admin/carlistan/console/"

  use_refresh_tokens                  = false
  full_scope_allowed                  = false
  backchannel_logout_session_required = false

  valid_redirect_uris = [
    "/admin/carlistan/console/*"
  ]
}
