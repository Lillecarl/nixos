variable "stdroles" {
  type = set(string)
}
resource "random_password" "this" {
  for_each         = var.stdroles
  length           = 16
  special          = true
  override_special = "!#."
}
resource "postgresql_role" "this" {
  for_each = var.stdroles
  login    = true
  name     = each.key
  password = random_password.this[each.key].result
}
resource "postgresql_database" "this" {
  for_each               = var.stdroles
  name                   = each.key
  owner                  = postgresql_role.this[each.key].name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
}
output "roles" {
  value = var.stdroles
}
output "secrets" {
  value     = { for k in var.stdroles : k => random_password.this[k] }
  sensitive = true
}
output "dbinfo" {
  sensitive = true
  value = {
    for k in var.stdroles : k => {
      pubhost = "postgres.lillecarl.com"
      host    = "cluster-rw.pg-cluster.svc.cluster.local"
      port    = 5432
      user    = k # username
      pass    = random_password.this[k].result
      name    = k # dbname
    }
  }
}
