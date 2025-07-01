{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "users";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
      username = lib.mkOption {
        default = "lillecarl";
        type = lib.types.str;
      };
      keys = lib.mkOption {
        default = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHZ3pA0vIXiKQuwfM1ks8TipeOxfDT9fgo4xMi9iiWr lillecarl@lillecarl.com"
        ];
        type = lib.types.listOf lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users = {
      enforceIdUniqueness = true;
      mutableUsers = false;

      users = {
        root = {
          openssh.authorizedKeys.keys = cfg.keys;
          autoSubUidGidRange = true;
        };
        ${cfg.username} = {
          uid = 1000;
          linger = true;
          hashedPassword = lib.mkDefault "$y$j9T$U4zBBS9RMV9YMttHauO8k0$V.KT/P/AdBTXXT8f6p9EIlCsZV5UnaPDgEVtUvUJU3C";
          createHome = true;
          isNormalUser = true;
          extraGroups = [
            "wheel"
          ];
          openssh.authorizedKeys.keys = cfg.keys;
          autoSubUidGidRange = true;
        };
      };
    };

    environment = {
      homeBinInPath = true;
      localBinInPath = true;
    };
  };
}
