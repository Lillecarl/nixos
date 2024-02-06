{ inputs
, ...
}:
{
  imports = [
    ./ags.nix
    ./alacritty.nix
    ./avizo.nix
    ./chromium.nix
    ./firefox.nix
    ./foot.nix
    ./hyprland.nix
    ./kitty.nix
    ./mako.nix
    ./obs.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./swaync.nix
    ./swaytools.nix
    ./theme.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
    ./wlogout.nix
    inputs.ags.homeManagerModules.default
  ];
}
