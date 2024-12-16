locals {
  kust_path = "${path.module}/rendered-kustomize"
  cnpg_path = "${local.kust_path}/cnpg"
}

data "http" "cnpg-manifest" {
  url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/releases/cnpg-1.25.0-rc1.yaml"
}

resource "local_file" "cnpg-release" {
  content  = data.http.cnpg-manifest.response_body
  filename = "${local.cnpg_path}/operator.yaml"
}

resource "local_file" "cnpg-kustomize" {
  content = yamlencode({
    resources = [
      "./operator.yaml"
    ]
  })
  filename = "${local.cnpg_path}/kustomization.yaml"

  provisioner "local-exec" {
    command = "kubectl apply -k ${local.cnpg_path} --server-side"
  }
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
    local_file.cnpg-kustomize
  ]
}

# data "kubectl_kustomize_documents" "cnpg-manifests" {
#     target = path.module

#     depends_on = [ local_file.cnpg-kustomize ]
# }

# resource "kubectl_manifest" "cnpg" {
#     count     = length(data.kubectl_kustomize_documents.cnpg-manifests.documents)
#     yaml_body = element(data.kubectl_kustomize_documents.cnpg-manifests.documents, count.index)
# }

# resource "kubectl_manifest" "test" {
#     yaml_body = data.http.manifest.response_body
#     server_side_apply = true
# }

# data "kustomization_overlay" "cnpg" {
#   resources = [
#     "${path.module}/cnpg.yaml"
#   ]
# }

# # first loop through resources in ids_prio[0]
# resource "kustomization_resource" "p0" {
#   for_each = data.kustomization_overlay.cnpg.ids_prio[0]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.cnpg.manifests[each.value])
#     : data.kustomization_overlay.cnpg.manifests[each.value]
#   )
# }

# # then loop through resources in ids_prio[1]
# # and set an explicit depends_on on kustomization_resource.p0
# # wait 2 minutes for any deployment or daemonset to become ready
# resource "kustomization_resource" "p1" {
#   for_each = data.kustomization_overlay.cnpg.ids_prio[1]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.cnpg.manifests[each.value])
#     : data.kustomization_overlay.cnpg.manifests[each.value]
#   )
#   wait = true
#   timeouts {
#     create = "2m"
#     update = "2m"
#   }

#   depends_on = [kustomization_resource.p0]
# }

# # finally, loop through resources in ids_prio[2]
# # and set an explicit depends_on on kustomization_resource.p1
# resource "kustomization_resource" "p2" {
#   for_each = data.kustomization_overlay.cnpg.ids_prio[2]

#   manifest = (
#     contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#     ? sensitive(data.kustomization_overlay.cnpg.manifests[each.value])
#     : data.kustomization_overlay.cnpg.manifests[each.value]
#   )

#   depends_on = [kustomization_resource.p1]
# }
