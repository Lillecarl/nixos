resource "kubectl_manifest" "keycloak-namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
YAML
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = "keycloak"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "keycloak"
  version    = "24.3.1"

  values = [
    (<<YAML
postgresql:
  enabled: false
auth:
  adminUser: carl
  adminPassword: carl
ingress:
  enabled: true
  tls: true
  hostname: keycloak.lillecarl.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
externalDatabase:
  existingSecret: "cluster-keycloak"
  existingSecretHostKey: "host"
  existingSecretPortKey: "port"
  existingSecretUserKey: "user"
  existingSecretPasswordKey: "pass"
  existingSecretDatabaseKey: "database"
  annotations: {}
YAML
    )
  ]
  depends_on = [
    kubectl_manifest.keycloak-namespace,
    kubectl_manifest.cnpg_resource,
  ]
}
