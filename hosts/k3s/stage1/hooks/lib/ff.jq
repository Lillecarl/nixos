#!/usr/bin/env -S jq -f

# Fast Filter (ff.jq) - Prefilter to reduce context.json size
# This removes unnecessary data while keeping essential info for nodeIPAM

.[0].snapshots
| {
  node: (
    .node
    | map({
        metadata: {
          name: .object.metadata.name
        },
        addresses: (
          .object.status.addresses // []
          | map(select(.type == "ExternalIP"))
        )
      })
  ),
  service: (
    .service
    | map({
        metadata: {
          name: .object.metadata.name,
          namespace: .object.metadata.namespace,
          uid: .object.metadata.uid
        },
        spec: {
          type: .object.spec.type,
          loadBalancerClass: .object.spec.loadBalancerClass
        },
        status: {
          loadBalancer: .object.status.loadBalancer
        }
      })
  ),
  slice: (
    .slice
    | map({
        metadata: {
          name: .object.metadata.name,
          namespace: .object.metadata.namespace,
          ownerReferences: .object.metadata.ownerReferences
        },
        endpoints: (
          .object.endpoints // []
          | map({
              addresses: .addresses,
              nodeName: .nodeName
            })
        )
      })
  | map(select(.metadata.ownerReferences != null)))
}
