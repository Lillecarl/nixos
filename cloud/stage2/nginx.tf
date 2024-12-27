module "nginx" {
  count     = 1
  source    = "../modules/nginx"
  paths     = local.paths
  k8s_force = false
}
