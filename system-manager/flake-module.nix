{ inputs
, lib
, flake-utils
, ...
}:
{
  flake = {
    systemConfigs.default = inputs.system-manager.lib.makeSystemConfig {
      #system = flake-utils.lib.system.x86_64-linux;
      modules = [
        ./default.nix
      ];
    };
  };
}
