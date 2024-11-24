{ inputs
, pkgs
, self
, ...
}:
{
  imports = [
    ./alacritty.nix
    ./avizo.nix
    ./chromium.nix
    ./cliphist.nix
    ./firefox.nix
    ./foot.nix
    ./kitty.nix
    ./mako.nix
    ./mpv.nix
    ./niri.nix
    ./obs.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./swaync.nix
    ./swaytools.nix
    ./theme.nix
    ./udiskie.nix
    ./vieb.nix
    ./waybar.nix
    ./wlogout.nix
  ];
}
