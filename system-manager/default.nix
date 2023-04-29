{ config
, lib
, pkgs
, ...
}: {
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    #nixpkgs.overlays = [ ./overlay.nix ];

    environment.etc = {
      "system-manager.conf.test".text = ''
        it works!!!!!
      '';
    };
  };
}
