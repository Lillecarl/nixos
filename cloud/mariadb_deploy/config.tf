variable "stdroles" {
  type = set(string)
}
resource "random_password" "this" {
  for_each         = var.stdroles
  length           = 16
  special          = true
  override_special = "!#."
}
resource "kubectl_manifest" "secret" {
  for_each = var.stdroles
  yaml_body = yamlencode({
    apiVersion = "v1"
    data = {
      pass = base64encode(random_password.this[each.key].result)
    }
    kind = "Secret"
    metadata = {
      name      = each.key
      namespace = "mariadb-deploy"
    }
    type = "Opaque"
  })
  depends_on = []

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "user" {
  for_each = var.stdroles
  yaml_body = yamlencode({
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "User"
    metadata = {
      name      = each.key
      namespace = "mariadb-deploy"
    }
    spec = {
      cleanupPolicy = "Delete"
      host          = "%"
      mariaDbRef = {
        name = "mariadb"
      }
      passwordSecretKeyRef = {
        key  = "pass"
        name = each.key
      }
      requeueInterval = "30s"
      retryInterval   = "5s"
    }
  })
  depends_on = []

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "grant" {
  for_each = var.stdroles
  yaml_body = yamlencode({
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Grant"
    metadata = {
      name      = each.key
      namespace = "mariadb-deploy"
    }
    spec = {
      cleanupPolicy = "Delete"
      database      = each.key
      grantOption   = true
      host          = "%"
      mariaDbRef = {
        name = "mariadb"
      }
      privileges = [
        "ALL PRIVILEGES",
      ]
      requeueInterval = "30s"
      retryInterval   = "5s"
      table           = "*"
      username        = each.key
    }
  })
  depends_on = []

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "database" {
  for_each = var.stdroles
  yaml_body = yamlencode({
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Database"
    metadata = {
      name      = each.key
      namespace = "mariadb-deploy"
    }
    spec = {
      characterSet  = "utf8"
      cleanupPolicy = "Delete"
      collate       = "utf8_general_ci"
      mariaDbRef = {
        name = "mariadb"
      }
      requeueInterval = "30s"
      retryInterval   = "5s"
    }
  })
  depends_on = []

  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
output "dbinfo" {
  sensitive = true
  value = {
    for k in var.stdroles : k => {
      pubhost = "mariadb.lillecarl.com"
      host    = "mariadb.mariadb-deploy.svc.k8s.lillecarl.com"
      port    = 3306
      user    = k # username
      pass    = random_password.this[k].result
      name    = k # dbname
    }
  }
}
