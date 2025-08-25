{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./audiovideo.nix
    ./avizo.nix
    ./chromium.nix
    ./cliphist.nix
    ./eww.nix
    ./vscode.nix
    ./firefox.nix
    ./foot.nix
    ./kitty.nix
    ./mako.nix
    ./mpris.nix
    ./mpv.nix
    ./niri.nix
    ./obs.nix
    ./packages.nix
    ./rofi.nix
    ./swaybg.nix
    ./swayidlelock.nix
    ./swaync.nix
    ./theme.nix
    ./udiskie.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  config = { };
}
