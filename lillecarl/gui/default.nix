{ config, pkgs, ... }:
{
  imports = [
    ./brave.nix
    ./firefox.nix
    ./vscode.nix
    ./wezterm.nix
    ./kde.nix
  ];
  home.file = {
    ".config/qtile/autostart.sh".source = ../dotfiles/.config/qtile/autostart.sh;
    ".config/qtile/config.py".source = ../dotfiles/.config/qtile/config.py;
    ".config/qtile/battery.py".source = ../dotfiles/.config/qtile/battery.py;
  };


  home.packages = with pkgs; [
    # Desktop item overrides
    #(hiPrio vscode-wayland)
    #(hiPrio slack-wayland)
    #(hiPrio brave-wayland)

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
