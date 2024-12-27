variable "CF_DNS_TOKEN" {}
module "external-dns" {
  source       = "../modules/external-dns"
  paths        = local.paths
  stage0       = false
  stage1       = true
  stage2       = true
  k8s_force    = false
  CF_DNS_TOKEN = var.CF_DNS_TOKEN
}
