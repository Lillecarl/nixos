module "nginx" {
  source    = "../modules/nginx"
  paths     = local.paths
  stage0    = true
  stage1    = false
  stage2    = false
  k8s_force = false
}
