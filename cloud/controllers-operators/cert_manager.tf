module "cert_manager" {
  source       = "../modules/cert-manager"
  paths        = local.paths
  stage0       = false
  stage1       = true
  stage2       = true
  k8s_force    = false
  CF_DNS_TOKEN = var.CF_DNS_TOKEN
}
