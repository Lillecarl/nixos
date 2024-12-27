module "external-dns" {
  source       = "../modules/external-dns"
  paths        = local.paths
  stage0       = true
  stage1       = false
  stage2       = false
  k8s_force    = false
  CF_DNS_TOKEN = "" # We're only deploying namespace and CRD here
}
