{ pkgs, ... }: {
  imports = [
    ./brave.nix
    ./firefox.nix
    ./kde.nix
    ./qutebrowser.nix
    ./vscode.nix
    ./wezterm.nix
  ];
  home.file = {
  };

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
    #vlc # VLC sucks in comparision to MPV
  ];
}
