{ inputs
, pkgs
, ...
}:
{
  imports = [
    ../../modules/hm/swaync.nix
    ../../modules/hm/wezterm.nix
    ./ags.nix
    ./packages.nix
    ./qutebrowser.nix
    ./rofi.nix
    ./theme.nix
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
