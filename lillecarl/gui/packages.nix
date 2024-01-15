{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ferdium # Web multiplexer
    bitwarden # Password manager
    xfce.ristretto # Image viewer
    pcmanfm # File manager
    neovide # Neovim GUI
    dfeet # GUI browser for dbus
    mpv # Video player
    vlc # VLC sucks in comparision to MPV
    wev # Like xev but for wayland, displays which keys you're pressing
    gitg # Git GUI for viewing branches
    signal-desktop # Signal messenger, useful to copy-paste stuff to your phone
    kleopatra # GUI for GPG
  ];

  services.flatpak = {
    enable = true;
    packages = [
      "com.spotify.Client"
      "im.riot.Riot"
    ];
    update.auto.enable = true;
  };
}
