{ kubenixYAML, lib, ... }:
let
in
{
  terraform = {
    required_providers = {
      kubectl = {
        source = "gavinbunney/kubectl";
        version = "1.19.0";
      };
    };
  };
  locals.ignore_fields = {
    "/api/v1/namespaces/cilium/secrets/cilium-ca" = [
      "data"
    ];
    "/api/v1/namespaces/cilium/secrets/hubble-server-certs" = [
      "data"
    ];
  };

  data.kubectl_file_documents.this = {
    content =
      lib.tfRef # terraform
        ''file("${kubenixYAML}")'';
  };

  resource.kubectl_manifest.this = {
    for_each =
      lib.tfRef # terraform
        ''data.kubectl_file_documents.this.manifests'';
    yaml_body =
      lib.tfRef # terraform
        ''each.value'';
    ignore_fields =
      lib.tfRef # terraform
        ''try(local.ignore_fields[each.key], null)'';
    server_side_apply = true;
    wait_for_rollout = false;

  };
}
