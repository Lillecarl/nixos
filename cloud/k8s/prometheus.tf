locals {
  prometheus_path = "${local.kust_path}/prometheus"
}

data "http" "prometheus-manifest" {
  url = "https://github.com/prometheus-operator/prometheus-operator/releases/download/v0.79.0/bundle.yaml"
}

resource "local_file" "prometheus-release" {
  content  = data.http.prometheus-manifest.response_body
  filename = "${local.prometheus_path}/operator.yaml"
}

resource "local_file" "prometheus-extras" {
  content  = <<YAML
---
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/metrics
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs: ["get", "list", "watch"]
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: default
---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
spec:
  serviceAccountName: prometheus
YAML
  filename = "${local.prometheus_path}/extras.yaml"
}

data "kustomization_overlay" "prometheus-manifests" {
  namespace = "prometheus"
  resources = [
    "${local_file.prometheus-release.filename}",
    "${local_file.prometheus-extras.filename}",
  ]
} 

resource "kubectl_manifest" "prometheus0" {
  for_each = data.kustomization_overlay.prometheus-manifests.ids_prio[0]

  yaml_body = data.kustomization_overlay.prometheus-manifests.manifests[each.value]
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus1" {
  for_each = data.kustomization_overlay.prometheus-manifests.ids_prio[1]

  yaml_body = data.kustomization_overlay.prometheus-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.prometheus0]
}

resource "kubectl_manifest" "prometheus2" {
  for_each = data.kustomization_overlay.prometheus-manifests.ids_prio[2]

  yaml_body = data.kustomization_overlay.prometheus-manifests.manifests[each.value]
  server_side_apply = true
  depends_on = [kubectl_manifest.prometheus1]
}
