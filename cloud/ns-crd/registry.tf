module "registry" {
  source            = "../modules/registry"
  paths             = local.paths
  stage0            = true
  stage1            = false
  stage2            = false
  k8s_force         = false
  registry_htpasswd = "" # We're only deploying namespace here
}
