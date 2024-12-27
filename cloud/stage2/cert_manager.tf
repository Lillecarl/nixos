module "cert_manager" {
  count        = 1
  source       = "../modules/cert-manager"
  paths        = local.paths
  k8s_force    = false
  CF_DNS_TOKEN = var.CF_DNS_TOKEN
}
