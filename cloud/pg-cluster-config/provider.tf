variable "postgres-admin-username" {}
variable "postgres-admin-password" {}
variable "postgres-admin-hostname" {}
variable "postgres-admin-portnumb" { type = number }
provider "postgresql" {
  host            = var.postgres-admin-hostname
  port            = var.postgres-admin-portnumb
  username        = var.postgres-admin-username
  password        = var.postgres-admin-password
  database        = "postgres"
  sslmode         = "require"
  connect_timeout = 15
}
