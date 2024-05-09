{ config, pkgs, ... }:
{
  xdg.configFile."distrobox_bin".source = pkgs.symlinkJoin {
    name = "distrobox_bin";
    paths = with config; [
      nix.package
      programs.atuin.package
      programs.fish.package
      programs.ripgrep.package
      programs.starship.package
      wayland.windowManager.hyprland.package
    ];
  };
}
