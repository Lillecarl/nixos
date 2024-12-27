module "cnpg" {
  source    = "../modules/cnpg"
  paths     = local.paths
  stage0    = false
  stage1    = true
  stage2    = true
  k8s_force = false
}

