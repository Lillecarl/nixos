provider "grafana" {
  url  = "https://grafana.lillecarl.com"
  auth = "admin:${local.rs.stage1.secrets["grafana-admin"].password}"
}
