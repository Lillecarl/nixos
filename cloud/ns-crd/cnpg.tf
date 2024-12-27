module "cnpg" {
  source    = "../modules/cnpg"
  paths     = local.paths
  stage0    = true
  stage1    = false
  stage2    = false
  k8s_force = false
}
