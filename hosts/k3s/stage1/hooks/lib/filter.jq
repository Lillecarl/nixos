#!/usr/bin/env -S jq -f

def serviceIndex(namespace; name):
  namespace + "-" + name;

.[0].snapshots
| walk(if type == "object" then del(.managedFields) else . end)
| {
    nodeips: (
      .node
      | map({
          (.object.metadata.name): (
            .object.status.addresses
            | map(select(.type | IN("ExternalIP", "InternalIP")))
          )
        })
      | add
    ),
    services: (
      .service
      | map({
          (serviceIndex(.object.metadata.namespace; .object.metadata.name)): (
            .object.spec.ports
            | map({
                port: .port,
                protocol: .protocol
              })
          )
        })
      | add
    ),
    slices: (
      .slice
    )
  }
