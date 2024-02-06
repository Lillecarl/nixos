{ inputs
, pkgs
, ...
}:
{
  imports = [
    ../../modules/hm/swaync.nix
    ../../modules/hm/wezterm.nix
    ./ags.nix
    ./foot.nix
    ./hyprland.nix
    ./kitty.nix
    ./mpv.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./swaync.nix
    ./swaytools.nix
    ./theme.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
    inputs.ags.homeManagerModules.default
  ];

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      input-overlay
      looking-glass-obs
      obs-gstreamer
      obs-vaapi
      obs-vkcapture
      wlrobs
    ];
  };
}
