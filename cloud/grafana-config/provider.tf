variable "grafana_admin_pass" {}
provider "grafana" {
  url  = "https://grafana.lillecarl.com"
  auth = "admin:${var.grafana_admin_pass}"
}
