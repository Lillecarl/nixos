{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [ rofimoji rofi-rbw ];
  };

  home.packages = with pkgs; [
    wofi # Wayland rofi?
    # Chat apps
    element-desktop # Element Slack app
    teams # Microsoft Teams collaboration suite (Electron)
    slack # Team collaboration chat (Electron)
    discord # Gaming chat application
    zoom # Meetings application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    #vlc # VLC sucks in comparision to MPV

  ];
}
