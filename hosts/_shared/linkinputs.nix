{ lib, config, inputs, modulesPath, ... }:
let
  modName = "linkinputs";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
      ignoreInputs = lib.mkOption {
        default = [
          "nixpkgsOnFS"
          "nixpkgs-master"
          "nixpkgs-stable"
        ];
        description = ''
          Don't link inputs with these names (to prevent copying to store)
        '';
        type = lib.types.listOf lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.etc = lib.pipe inputs [
      # Don't link inputs listed in ps.linkinputs.ignoreInputs
      (x: lib.filterAttrs (key: val: !lib.any (x: x == key) cfg.ignoreInputs) x)
      (
        x:
        lib.mapAttrs' (key: val: {
          name = "flakeinputs/${key}";
          value = {
            source = "${val}";
          };
        }) x
      )
    ];
  };
}
