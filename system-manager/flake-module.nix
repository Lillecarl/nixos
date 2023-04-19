{ inputs
, lib
, flake-utils
, ...
}: {
  flake = {
    systemConfigs.default = inputs.system-manager.lib.makeSystemConfig {
      modules = [
        ./default.nix
      ];
    };
  };
}
