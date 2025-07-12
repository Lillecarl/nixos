#!/usr/bin/env -S jq -f

# Create service index from namespace and name
def serviceIndex(namespace; name):
  namespace + "-" + name;

# Process Kubernetes snapshots
# Assumptions (safe to assume in this context):
# - .node, .service, .slice keys always exist
# - .object.metadata.name is mandatory for services and nodes
# - .object.metadata.namespace is mandatory for services (nodes don't have namespaces)
# - .object.spec.ports may be null/missing for services
# - .object.status.addresses may be null/missing for nodes
.[0].snapshots
| walk(if type == "object" then del(.managedFields) else . end)
| 
# Extract nodeName from endpointslices and create service -> nodeName mapping
(
  .slice
  | map(
      select(.object.metadata.ownerReferences // [] | length > 0)
      | {
          key: serviceIndex(.object.metadata.namespace; .object.metadata.ownerReferences[0].name),
          value: (
            .object.endpoints // []
            | map(select(.nodeName))
            | map(.nodeName)
            | unique
          )
        }
    )
  | map(select(.value | length > 0))
  | from_entries
) as $serviceNodes
|
{
  nodeips: (
    .node
    | map({
        key: .object.metadata.name,
        value: (
          .object.status.addresses // []
          | map(select(.type | IN("ExternalIP", "InternalIP")))
        )
      })
    | from_entries
  ),
  services: (
    .service
    | map({
        key: serviceIndex(.object.metadata.namespace; .object.metadata.name),
        value: {
          ports: (
            .object.spec.ports // []
            | map({
                port: .port,
                protocol: .protocol
              })
          ),
          nodeNames: ($serviceNodes[serviceIndex(.object.metadata.namespace; .object.metadata.name)] // [])
        }
      })
    | from_entries
  ),
  slices: .slice
}
