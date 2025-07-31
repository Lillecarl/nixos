data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  kustomize_options {
    load_restrictor = "none"
  }
}
resource "kubernetes_labels" "this" {
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = "hetzner1"
  }
  labels = {
    "node-access" = "ssh"
  }
}
resource "kubectl_manifest" "this" {
  for_each  = data.kustomization_overlay.this.ids
  yaml_body = data.kustomization_overlay.this.manifests[each.value]

  force_conflicts   = true
  apply_only        = true
  server_side_apply = true
  wait              = true
  depends_on = [
    kubernetes_labels.this
  ]
}

