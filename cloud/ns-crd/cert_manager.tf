module "cert_manager" {
  source       = "../modules/cert-manager"
  paths        = local.paths
  stage0       = true
  stage1       = false
  stage2       = false
  k8s_force    = false
  CF_DNS_TOKEN = ""
}
