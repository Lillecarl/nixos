locals {
  cnpg-file-path        = "${path.module}/cnpg"
  keycloak_password_raw = "${random_pet.cnpg_password["keycloak"].id}15"
  cnpg-vars = {
    namespace         = "cnpg"
    keycloak_username = base64encode("keycloak")
    keycloak_password = base64encode(local.keycloak_password_raw)
  }
}

data "kubectl_file_documents" "cnpg_operator_manifest" {
  content = file(local.cnpg_bundle)
}

resource "kubectl_manifest" "cnpg_operator_manifest" {
  for_each          = data.kubectl_file_documents.cnpg_operator_manifest.manifests
  yaml_body         = each.value
  server_side_apply = true
}

data "local_file" "cnpg_yaml" {
  for_each = fileset(local.cnpg-file-path, "*.yaml")
  filename = "${local.cnpg-file-path}/${each.key}"
}

resource "kubectl_manifest" "cnpg_resource" {
  for_each = data.local_file.cnpg_yaml

  yaml_body         = templatestring(each.value.content, local.cnpg-vars)
  server_side_apply = true
  depends_on = [
    kubectl_manifest.cnpg_operator_manifest
  ]
}

resource "random_pet" "cnpg_password" {
  for_each = toset(["keycloak"])

  length    = 3
  separator = "."
}
