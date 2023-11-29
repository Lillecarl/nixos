{ inputs
, pkgs
, ...
}:
{
  imports = [
    ./alacritty.nix
    ./avizo.nix
    ./firefox.nix
    ./hyprland.nix
    ./mako.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./sway.nix
    ./swaytools.nix
    ./theme.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
    inputs.nix-colors.homeManagerModules.default
  ];

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      input-overlay
      looking-glass-obs
      obs-backgroundremoval
      obs-gstreamer
      obs-vaapi
      obs-vkcapture
      wlrobs
    ];
  };
}
