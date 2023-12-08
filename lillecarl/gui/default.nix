{ inputs
, pkgs
, ...
}:
{
  imports = [
    ../../modules/hm/swaync.nix
    ../../modules/hm/wezterm.nix
    ./alacritty.nix
    ./avizo.nix
    ./firefox.nix
    ./foot.nix
    ./hyprland.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./sway.nix
    ./swaync.nix
    ./swaytools.nix
    ./theme.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
    inputs.stylix.homeManagerModules.stylix
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
