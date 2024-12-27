module "registry" {
  count           = 1
  source          = "../modules/registry"
  paths           = local.paths
  k8s_force       = false
  registry_secret = var.registry_secret
}
