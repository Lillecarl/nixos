locals {
  prometheus-file-path = "${path.module}/prometheus"
  prometheus-vars = {
    namespace = "prometheus"
  }
}

data "kubectl_file_documents" "prometheus_operator_manifest" {
  content = file(local.prometheus_bundle)
}

resource "kubectl_manifest" "prometheus_operator_manifest" {
  for_each          = data.kubectl_file_documents.prometheus_operator_manifest.manifests
  yaml_body         = each.value
  server_side_apply = true
}

data "local_file" "prometheus_yaml" {
  for_each = fileset(local.prometheus-file-path, "*.yaml")
  filename = "${local.prometheus-file-path}/${each.key}"
}

resource "kubectl_manifest" "prometheus_resource" {
  for_each = data.local_file.prometheus_yaml

  yaml_body         = templatestring(each.value.content, local.prometheus-vars)
  server_side_apply = true
  depends_on = [
    kubectl_manifest.prometheus_operator_manifest
  ]
}
