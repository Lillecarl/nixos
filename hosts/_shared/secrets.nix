{
  lib,
  config,
  inputs,
  ...
}:
let
  modName = "secrets";
  cfg = config.ps.${modName};
in
{
  imports = [
    inputs.agenix.nixosModules.age
  ];
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    age.secrets.cloudflare = {
      file = ../../secrets/cloudflare.age;
      inherit (config.users.users.acme) name group;
    };
  };
}
