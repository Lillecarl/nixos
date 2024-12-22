locals {
  registry-file-path = "${path.module}/registry"
  registry-vars = {
    namespace = "registry"
    userpass = base64encode("regadm:$2y$05$88ayJRNPFmy9dCpwEKd4uumcb88rvUTgg.x.lJpo0Mkn0Hs7.VNVi")
    service = "registry"
  }
}

data "local_file" "registry_yaml" {
  for_each = fileset(local.registry-file-path, "*.yaml")
  filename = "${local.registry-file-path}/${each.key}"
}

resource "kubectl_manifest" "registry_resource" {
  for_each = data.local_file.registry_yaml

  yaml_body = templatestring(each.value.content, local.registry-vars)
  server_side_apply = true
}
