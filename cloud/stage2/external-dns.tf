module "external-dns" {
  count        = 1
  source       = "../modules/external-dns"
  paths        = local.paths
  k8s_force    = false
  CF_DNS_TOKEN = var.CF_DNS_TOKEN
}
