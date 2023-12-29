{ inputs
, pkgs
, ...
}:
{
  imports = [
    ../../modules/hm/swaync.nix
    ../../modules/hm/wezterm.nix
    ./ags.nix
    ./alacritty.nix
    ./avizo.nix
    ./chromium.nix
    ./firefox.nix
    ./foot.nix
    ./hyprland.nix
    ./kitty.nix
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
