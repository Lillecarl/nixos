{ inputs, withSystem, ... }:
{
  flake = {
    systemConfigs.penguin = withSystem "aarch64-linux" (
      { pkgs, ... }:
      inputs.system-manager.lib.makeSystemConfig {
        modules = [
          (
            { nixosModulesPath, ... }:
            let
              lib = pkgs.lib;
            in
            {
              imports = [
                "${nixosModulesPath}/misc/ids.nix"
                "${nixosModulesPath}/services/databases/postgresql.nix"
              ];
              options = {
                system = {
                  stateVersion = lib.mkOption {
                    type = lib.types.str;
                    description = "TODO";
                  };
                  checks = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                    description = "TODO";
                  };
                };
              };
              config = {
                system-manager.allowAnyDistro = true;
                system.stateVersion = "24.05";
                services.postgresql.enable = true;
              };
            }
          )
        ];
        extraSpecialArgs = {
          inherit pkgs;
          nixosModulesPath = "${inputs.nixpkgs}/nixos/modules";
        };
      }
    );
  };
}
