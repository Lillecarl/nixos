variable "secrets" { type = set(string) }
locals {
  secrets = {
    for k in var.secrets : k =>
    replace(title("${random_pet.this[k].id}${random_integer.this[k].result}"), " ", ".")
  }
}
locals {
}
output "secrets" {
  sensitive = true
  value     = htpasswd_password.hash
}
output "paths" {
  value = local.paths
}
resource "random_pet" "this" {
  for_each = var.secrets

  length    = 3
  separator = " "
}
resource "random_integer" "this" {
  for_each = var.secrets

  min = 100
  max = 999
}
resource "random_password" "salt" {
  for_each = var.secrets

  length = 8
}
resource "htpasswd_password" "hash" {
  for_each = var.secrets

  password = local.secrets[each.key]
  salt     = random_password.salt[each.key].result
}

resource "random_password" "oauthproxy_cookie_secret" {
  length           = 32
  override_special = "-_"
}
output "oauthproxy_cookie_secret" {
  sensitive = true
  value     = random_password.oauthproxy_cookie_secret.result
}
resource "random_password" "postgrest_jwt_secret" {
  length  = 32
  special = false
}
output "postgrest_jwt_secret" {
  sensitive = true
  value     = random_password.postgrest_jwt_secret.result
}
