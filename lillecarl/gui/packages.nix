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
  ];
}
