{
  kubenixAttrs,
  kubenixYAML,
  pkgs,
  lib,
  ...
}:
let
  getKubernetesResourceName =
    manifest:
    let
      apiVersion = lib.replaceStrings [ "/" "." ] [ "-" "" ] manifest.apiVersion;
      # apiVersion = manifest.apiVersion;
      kind = manifest.kind;
      name = manifest.metadata.name;
      namespace = manifest.metadata.namespace or "none";
      attrName =
        if kind == "Namespace" then
          name
        else
          lib.strings.toLower "${apiVersion}_${namespace}_${kind}_${name}";
    in
    attrName;

  mapStringsDeep =
    f: value:
    if builtins.isString value then
      f value
    else if builtins.isAttrs value then
      lib.mapAttrs (name: mapStringsDeep f) value
    else if builtins.isList value then
      map (mapStringsDeep f) value
    else
      value;

  tfEscapeString =
    value:
    lib.replaceStrings
      [
        ("$" + "{") # Terraform will parse ${ as variable interpolation, same as Nix. Escaped as $${
        "%{" # Terraform will parse %{ as variable interpolation, escaped is %%{
      ]
      [
        ("$" + "$" + "{")
        "%%{"
      ]
      value;

  escapeStringsDeep = attrs: mapStringsDeep tfEscapeString attrs;

  kubenix_manifests = lib.listToAttrs (
    lib.map (manifest: {
      name = getKubernetesResourceName manifest;
      value = {
        raw = manifest;
        escaped = escapeStringsDeep manifest;
      };
    }) kubenixAttrs.items
  );

  kubectl_manifests = lib.mapAttrs (
    name: value: value.escaped // { JSON = lib.strings.toJSON value.escaped; }
  ) kubenix_manifests;

  kubernetes_manifests = lib.pipe kubenix_manifests [
    (x: lib.mapAttrs (name: value: escapeStringsDeep value) x)
  ];

  ignore_fields = {
    "v1_cilium_secret_cilium-ca" = [
      "data"
      "data[*]"
    ];
    "v1_cilium_secret_hubble-server-certs" = [
      "data"
      "data[*]"
    ];
  };
in
{
  terraform = {
    required_providers = {
      kubectl = {
        source = "gavinbunney/kubectl";
        version = "1.19.0";
      };
      kubernetes = {
        source = "hashicorp/kubernetes";
        version = "2.37.1";
      };
    };
  };
  provider.kubernetes.config_path = builtins.getEnv "KUBECONFIG";
  # locals.kubectl_manifests = lib.mapAttrs (name: value:
  #   value.JSON
  # ) kubectl_manifests;
  # locals.kubectl_manifests = lib.mapAttrsRecursive (
  #   name: value:
  #   let
  #     escape = value: lib.replaceStrings [ ("$" + "{") ] [ ("$" + "$" + "{") ] value;
  #   in
  #   if lib.isString value then escape value else
  #   if lib.isList value then
  # ) kubectl_manifests;
  locals.kubectl_manifests = mapStringsDeep (
    value:
    lib.replaceStrings
      [
        ("$" + "{") # Terraform will parse ${ as variable interpolation, same as Nix. Escaped as $${
        "%{" # Terraform will parse %{ as variable interpolation, escaped is %%{
      ]
      [
        ("$" + "$" + "{")
        "%%{"
      ]
      value
  ) kubectl_manifests;

  resource.kubectl_manifest = lib.mkMerge [
    (lib.mapAttrs (name: value: {
      # yaml_body =
      #   lib.tfRef # terraform
      #     ''file("${value.JSON}")'';
      yaml_body = value.JSON;
      server_side_apply = true;
      ignore_fields = if lib.hasAttr name ignore_fields then ignore_fields.${name} else [ ];
      depends_on =
        let
          namespace = value.Namespace or null;
          kind = value.Kind or null;
          hasNamespace = lib.hasAttr namespace kubectl_manifests;
        in
        lib.mkIf (namespace != null && kind != "Namespace" && hasNamespace) [
          "kubectl_manifest.${value.namespace}"
        ];
    }) kubectl_manifests)
  ];

  data.kubernetes_resource.example = {
    api_version = "v1";
    kind = "Secret";
    metadata = {
      name = "cilium-ca";
      namespace = "cilium";
    };
  };

  # resource.kubernetes_manifest = lib.mapAttrs (name: value: {
  #   manifest = value;
  #   lifecycle.ignore_changes = [
  #     "manifest.data"
  #   ];
  # }) kubernetes_manifests;
}
