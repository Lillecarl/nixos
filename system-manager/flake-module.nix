{ inputs
, ...
}: {
  flake = {
    nixosConfigs.default = inputs.system-manager.lib.makeSystemConfig {
      modules = [
        ./default.nix
      ];
    };
  };
}
