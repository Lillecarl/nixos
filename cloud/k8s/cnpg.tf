locals {
  kust_path = "${path.module}/rendered-kustomize"
  cnpg_path = "${local.kust_path}/cnpg"
  cnpg_release_file = "${local.cnpg_path}/operator.yaml"
  cnpg_extras_file = "${local.cnpg_path}/extras.yaml"
}

data "http" "cnpg-manifest" {
  url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-1.25.0-rc1.yaml"
}

resource "local_file" "cnpg-release" {
  content  = data.http.cnpg-manifest.response_body
  filename = "${local.cnpg_path}/operator.yaml"
}

resource "local_file" "cnpg-extras" {
  content  = <<YAML
---
YAML
  filename = "${local.cnpg_path}/extras.yaml"
}

data "kustomization_overlay" "cnpg-manifests" {
  resources = [
    (fileexists(local.cnpg_release_file ) ? "${local.cnpg_release_file }" : "${path.module}/empty.yaml"),
    (fileexists(local.cnpg_extras_file ) ? "${local.cnpg_extras_file }" : "${path.module}/empty.yaml"),
  ]
} 

resource "kubectl_manifest" "cnpg0" {
  for_each = data.kustomization_overlay.cnpg-manifests.ids_prio[0]

  yaml_body = data.kustomization_overlay.cnpg-manifests.manifests[each.value]
  server_side_apply = true
}

resource "kubectl_manifest" "cnpg1" {
  for_each = data.kustomization_overlay.cnpg-manifests.ids_prio[1]

  yaml_body = data.kustomization_overlay.cnpg-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.cnpg0]
}

resource "kubectl_manifest" "cnpg2" {
  for_each = data.kustomization_overlay.cnpg-manifests.ids_prio[2]

  yaml_body = data.kustomization_overlay.cnpg-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.cnpg1]
}

resource "kubectl_manifest" "cnpg-cluster" {
  yaml_body = <<YAML
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cnpg-cluster
spec:
  instances: 1

  storage:
    size: 1Gi
YAML

  depends_on = [
    kubectl_manifest.cnpg0,
    kubectl_manifest.cnpg1,
    kubectl_manifest.cnpg2,
  ]
}
