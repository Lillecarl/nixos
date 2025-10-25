{
  config,
  pkgs,
  lib,
  ...
}:
let
  moduleName = "local-path-provisioner";
  cfg = config.${moduleName};
in
{
  options.${moduleName} = {
    enable = lib.mkEnableOption moduleName;
  };
  config = lib.mkIf cfg.enable {
    importyaml.local-path-provisioner = {
      src = "https://raw.githubusercontent.com/rancher/local-path-provisioner/refs/heads/master/deploy/local-path-storage.yaml";
    };
  };
}
