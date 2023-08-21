{ pkgs, ... }: {
  imports = [
    ./brave.nix
    ./dunst.nix
    ./firefox.nix
    ./hyprland.nix
    ./kanshi.nix
    ./qutebrowser.nix
    ./swaytools.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
  ];
  home.file = { };

  home.packages = with pkgs; [
    # Web browsers
    brave

    # Office
    #libreoffice

    # Chat apps
    slack # Slack chat app
    element-desktop # Element Slack app
    teams-for-linux # Open-Source Teams Electron App
    discord # Gaming chat application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    vlc # VLC sucks in comparision to MPV

    wev # Like xev but for wayland, displays which keys you're pressing
    ulauncher-joined # Python based launcher
    dfeet # D-Bus explorer
  ];

  programs.obs-studio = {
    enable = true;

    plugins = builtins.attrValues {
      inherit (pkgs.obs-studio-plugins)
        wlrobs
        obs-vkcapture
        input-overlay
        obs-gstreamer
        looking-glass-obs
        obs-pipewire-audio-capture;
    };
  };
}
