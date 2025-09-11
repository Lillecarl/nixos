{
  kubenixAttrs,
  kubenixYAML,
  pkgs,
  lib,
  ...
}:
let
  # Takes a k8s manifest and returns a string that can be used as tf resource name
  getKubernetesResourceName =
    manifest:
    let
      namereplace = lib.replaceStrings [ "/" "." ":" ] [ "-" "" "" ];
      apiVersion = manifest.apiVersion;
      kind = manifest.kind;
      name = manifest.metadata.name;
      namespace = manifest.metadata.namespace or "none";
      attrName =
        if kind == "Namespace" then
          name
        else
          lib.strings.toLower "${apiVersion}_${namespace}_${kind}_${name}";
    in
    namereplace attrName;

  # Apply function to all strings in an attrset recursively through lists as well.
  mapStringsDeep =
    function: value:
    if lib.isStringLike value then
      function (toString value)
    else if lib.isAttrs value then
      lib.mapAttrs (name: mapStringsDeep function) value
    else if lib.isList value then
      map (mapStringsDeep function) value
    else
      value;

  # Escapes strings so variables aren't interpolated with ${} and %{}
  tfEscapeString =
    value:
    lib.replaceStrings
      [
        # Nix and tf shares this escape pattern
        "\${"
        # tf also interpolates %{}
        "%{"
      ]
      [
        "$\${"
        "%%{"
      ]
      value;

  # Escape
  escapeStringsDeep = attrs: mapStringsDeep tfEscapeString attrs;

  kubenix_manifests = lib.listToAttrs (
    lib.map (
      rawmanifest:
      let
        manifest = lib.filterAttrsRecursive (name: value: name != "kubenix/hash") rawmanifest;
      in
      {
        name = getKubernetesResourceName manifest;
        value = {
          raw = manifest;
          escaped = lib.tf.escapeEscapeDeep manifest;
        };
      }
    ) kubenixAttrs.items
  );

  kubectl_manifests = lib.mapAttrs (
    name: value: value.escaped // { JSON = lib.strings.toJSON value.escaped; }
  ) kubenix_manifests;

  kubernetes_manifests = lib.mapAttrs (name: value: value.escaped) kubenix_manifests;

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
  # locals.kubectl_manifests = kubectl_manifests;
  locals.test = escapeStringsDeep {
    asdf = "fdsa";
    hello = pkgs.hello;
  };

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
}
