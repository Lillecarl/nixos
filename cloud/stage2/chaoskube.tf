module "chaoskube" {
  count     = 1
  source    = "../modules/chaoskube"
  paths     = local.paths
  k8s_force = false
}
