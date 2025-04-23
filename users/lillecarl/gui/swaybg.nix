{
  lib,
  config,
  pkgs,
  ...
}:
let
  backgroundImage = pkgs.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-watersplash.png?raw=true";
    sha256 = "sha256-6Gdjzq3hTvUH7GeZmZnf+aOQruFxReUNEryAvJSgycQ=";
  };
in
{
  config = lib.mkIf config.ps.gui.enable {
    systemd.user.services.swaybg = {
      Unit = {
        Description = "Sway background image daemon";
        PartOf = [ config.wayland.systemd.target ];
      };

      Service = {
        ExecStart = "${lib.getExe pkgs.swaybg} --image ${backgroundImage} --mode center";
      };
      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };
    };
  };
}
