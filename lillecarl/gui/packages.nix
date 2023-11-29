{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xfce.ristretto
    # Web browsers
    pcmanfm

    # Terminal
    alacritty

    # gui neovim
    neovide

    dfeet # GUI browser for dbus

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    vlc # VLC sucks in comparision to MPV

    wev # Like xev but for wayland, displays which keys you're pressing
    dfeet # D-Bus explorer
  ];
}
