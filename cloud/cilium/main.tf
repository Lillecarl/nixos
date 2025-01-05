variable "paths" { type = map(string) }
variable "k8s_force" { type = bool }
variable "deploy" { type = bool }
locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-secrets = toset([
    "_/Secret/kube-system/cilium-ca",
    "_/Secret/kube-system/hubble-server-certs",
  ])
  id-this-configmap = "_/ConfigMap/kube-system/cilium-config"
  ids-this-stage1 = toset(var.deploy ? [
    for id in data.kustomization_overlay.this.ids_prio[1] :
    id if(
      !contains(local.ids-this-secrets, id) &&
      id != local.id-this-configmap
    )
  ] : [])
  ids-this-stage2 = var.deploy ? data.kustomization_overlay.this.ids_prio[2] : []
  helm_values = {
    kubeProxyReplacement = true
    k8sServiceHost       = "65.21.63.133"
    k8sServicePort       = "6443"
    tunnelProtocol       = "geneve"
    routingMode          = "tunnel"
    cluster              = { name = "default" }
    ipam = { operator = {
      clusterPoolIPv4PodCIDRList = "10.42.0.0/16"
      # clusterPoolIPv6PodCIDRList = "2a01:4f9:c01f:e028::/64"
    } }
    operator     = { replicas = 1 }
    hostFirewall = { enabled = true }
    ipv6         = { enabled = true }
    bpf          = { masquerade = true }
    cgroup = {
      autoMount = { enabled = false }
      hostRoot  = "/sys/fs/cgroup"
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  helm_charts {
    name          = "cilium"
    release_name  = "cilium"
    namespace     = "kube-system"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  helm_globals {
    chart_home = var.paths.charts
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = var.paths.helm-path
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = local.ids-this-stage0
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = var.k8s_force
  apply_only        = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "secrets" {
  for_each   = local.ids-this-secrets
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  lifecycle {
    ignore_changes = [
      yaml_body,
    ]
  }

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "configmap" {
  yaml_body  = data.kustomization_overlay.this.manifests[local.id-this-configmap]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  force_conflicts   = var.k8s_force
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
