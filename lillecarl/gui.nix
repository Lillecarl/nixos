{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [ rofimoji rofi-rbw ];
  };

  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.xonsh
      vscodevim.vim
      EditorConfig.EditorConfig
      bbenoist.nix
    ];
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
