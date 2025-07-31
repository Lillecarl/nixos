data "kustomization_overlay" "this" {
  resources = [for file in tolist(fileset(path.module, "*.yaml")) : "${path.module}/${file}"]
  namespace = "pg-cluster"
  secret_generator {
    name = "postgrest-db"
    type = "Opaque"
    literals = [
      "host=${local.rs.pg-cluster-config.dbinfo.postgrest.host}",
      "port=${local.rs.pg-cluster-config.dbinfo.postgrest.port}",
      "name=${local.rs.pg-cluster-config.dbinfo.postgrest.name}",
      "user=${local.rs.pg-cluster-config.dbinfo.postgrest.user}",
      "pass=${local.rs.pg-cluster-config.dbinfo.postgrest.pass}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  secret_generator {
    name = "postgrest-jwt"
    type = "Opaque"
    literals = [
      "secret=${local.rs.stage1.postgrest_jwt_secret}",
      "rs256=${local.rs.keycloak-config.realm_RS256_public_key}",
      "jwks=${local.rs.keycloak-config.realm_RS256_jwks}",
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  kustomize_options {
    load_restrictor = "none"
  }
}
resource "kubectl_manifest" "resources" {
  for_each   = data.kustomization_overlay.this.ids
  yaml_body  = data.kustomization_overlay.this.manifests[each.value]
  depends_on = []

  force_conflicts   = false
  apply_only        = false
  server_side_apply = true
  wait              = true
  timeouts { create = "1m" }
}

