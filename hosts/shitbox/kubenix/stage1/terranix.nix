{ kubenixYAML, lib, ... }:
{
  terraform = {
    required_providers = {
      kubectl = {
        source = "gavinbunney/kubectl";
        version = "1.19.0";
      };
    };
  };
  data.kubectl_file_documents.this = {
    content = lib.tfRef "file(\"${kubenixYAML}\")";
  };
  resource.kubectl_manifest.this = {
    for_each = lib.tfRef "data.kubectl_file_documents.this.manifests";
    yaml_body = lib.tfRef "each.value";
    server_side_apply = true;
    wait_for_rollout = false;
  };
}
