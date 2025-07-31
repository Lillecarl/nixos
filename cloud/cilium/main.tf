locals {
  ids-this-stage0 = data.kustomization_overlay.this.ids_prio[0]
  ids-this-secrets = toset([
    "_/Secret/kube-system/cilium-ca",
    "_/Secret/kube-system/hubble-server-certs",
  ])
  id-this-configmap = "_/ConfigMap/kube-system/cilium-config"
  ids-this-stage1 = toset([
    for id in data.kustomization_overlay.this.ids_prio[1] :
    id if(
      !contains(local.ids-this-secrets, id) &&
      id != local.id-this-configmap
    )
  ])
  ids-this-stage2 = data.kustomization_overlay.this.ids_prio[2]
  helm_values = {
    l7proxy              = true
    kubeProxyReplacement = true
    k8sServiceHost       = "127.0.0.1"
    k8sServicePort       = "6443"
    tunnelProtocol       = "geneve"
    routingMode          = "tunnel"
    cluster              = { name = "default" }
    nodeIPAM             = { enabled = true }
    defaultLBServiceIPAM = "nodeipam"
    ipam = { operator = {
      clusterPoolIPv4PodCIDRList = "10.42.0.0/16"
      # clusterPoolIPv6PodCIDRList = "2a01:4f9:c01f:e028::/64"
    } }
    operator     = { replicas = 1 }
    hostFirewall = { enabled = true }
    ipv6         = { enabled = true }
    bpf = {
      masquerade        = true
      hostLegacyRouting = true
    }
    cgroup = {
      autoMount = { enabled = false }
      hostRoot  = "/sys/fs/cgroup"
    }
    ingressController = {
      enabled          = false
      loadbalancerMode = "shared"
      service = {
        loadBalancerClass = "io.cilium/node"
      }
    }
  }
}
data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  helm_charts {
    name          = "cilium"
    include_crds  = true
    values_inline = yamlencode(local.helm_values)
  }
  helm_globals {
    chart_home = local.chartParentPath
  }
  kustomize_options {
    load_restrictor = "none"
    enable_helm     = true
    helm_path       = local.helmBinPath
  }
}
resource "kubectl_manifest" "stage0" {
  for_each   = local.ids-this-stage0
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

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

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "configmap" {
  yaml_body  = data.kustomization_overlay.this.manifests[local.id-this-configmap]
  depends_on = [kubectl_manifest.stage0]

  force_conflicts   = true
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage1" {
  for_each   = local.ids-this-stage1
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage0]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
resource "kubectl_manifest" "stage2" {
  for_each   = local.ids-this-stage2
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = [kubectl_manifest.stage1]

  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}
