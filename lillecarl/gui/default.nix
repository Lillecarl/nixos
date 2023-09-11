{ pkgs, ... }: {
  imports = [
    ./brave.nix
    ./firefox.nix
    ./hyprland.nix
    ./mako.nix
    ./qutebrowser.nix
    ./swaytools.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
    ./wob.nix
  ];
  home.file = { };

  home.packages = with pkgs; [
    # Web browsers
    brave
    # firefox # firefox is installed through a module

    # Office
    #libreoffice

    dfeet # GUI browser for dbus

    # Chat apps
    slack # Slack chat app
    element-desktop-wayland # Element Slack app
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
