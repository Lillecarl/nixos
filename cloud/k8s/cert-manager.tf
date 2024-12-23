locals {
  cert-manager-file-path = "${path.module}/cert-manager"
  cert-manager-vars = {
    namespace           = "cert-manager"
    cloudflare-apitoken = var.CF_DNS_TOKEN
  }
}
variable "CF_DNS_TOKEN" {}

data "kubectl_file_documents" "cert-manager_operator_manifest" {
  content = file(local.cert-manager_bundle)
}

resource "kubectl_manifest" "cert-manager_operator_manifest" {
  for_each          = data.kubectl_file_documents.cert-manager_operator_manifest.manifests
  yaml_body         = each.value
  server_side_apply = true
}

data "local_file" "cert-manager_yaml" {
  for_each = fileset(local.cert-manager-file-path, "*.yaml")
  filename = "${local.cert-manager-file-path}/${each.key}"
}

resource "kubectl_manifest" "cert-manager_resource" {
  for_each = data.local_file.cert-manager_yaml

  yaml_body         = templatestring(each.value.content, local.cert-manager-vars)
  server_side_apply = true
  depends_on = [
    kubectl_manifest.cert-manager_operator_manifest
  ]
}
