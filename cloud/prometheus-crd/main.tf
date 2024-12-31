variable "paths" { type = map(string) }
data "kustomization_overlay" "this" {
  resources = [var.paths.prometheus-bundle]
  kustomize_options {
    load_restrictor = "none"
  }
}
resource "kubectl_manifest" "this" {
  for_each  = data.kustomization_overlay.this.ids_prio[0]
  yaml_body = data.kustomization_overlay.this.manifests[each.value]

  force_conflicts   = true
  apply_only        = true
  server_side_apply = true
  wait              = true
}

