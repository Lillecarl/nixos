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
resource "keycloak_user" "lillecarl" {
  realm_id       = local.realm_id
  first_name     = "Carl"
  last_name      = "Andersson"
  email          = "lillecarl@lillecarl.com"
  email_verified = true
  username       = "lillecarl"
  initial_password {
    value     = var.keycloak_admin_pass
    temporary = false
  }
}
resource "keycloak_user_groups" "lillecarl" {
  realm_id = local.realm_id
  user_id  = keycloak_user.lillecarl.id

  group_ids = [
    keycloak_group.grafana-admin.id,
    keycloak_group.kubernetes-admin.id,
    keycloak_group.admin.id,
  ]
}

data "keycloak_role" "admin" {
  realm_id = data.keycloak_realm.realm.id
  name     = "admin"
}
resource "keycloak_group" "admin" {
  realm_id = local.realm_id
  name     = "admin"
}
resource "keycloak_group_roles" "admin" {
  realm_id = data.keycloak_realm.realm.id
  group_id = keycloak_group.admin.id

  role_ids = [data.keycloak_role.admin.id, ]
}

resource "keycloak_role" "grafana-admin" {
  realm_id = data.keycloak_realm.realm.id
  name     = "grafana-admin"
}
resource "keycloak_group" "grafana-admin" {
  realm_id = local.realm_id
  name     = "grafana-admin"
}
resource "keycloak_group_roles" "grafana-admin" {
  realm_id = data.keycloak_realm.realm.id
  group_id = keycloak_group.grafana-admin.id

  role_ids = [keycloak_role.grafana-admin.id, ]
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
