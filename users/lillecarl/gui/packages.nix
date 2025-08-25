{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ps.gui.enable {
    home.packages =
      with pkgs;
      [
        stremio # Video player with plugins to fetch content from questionable sources
        xfce.ristretto # Image viewer
        pcmanfm # File manager
        neovide # Neovim GUI
        d-spy # GUI browser for dbus
        mpv # Video player
        vlc # VLC sucks in comparison to MPV
        wev # Like xev but for wayland, displays which keys you're pressing
        gitg # Git GUI for viewing branches
        signal-desktop # Signal messenger, useful to copy-paste stuff to your phone
        gpa # GUI for PGP
        google-chrome # Only use this when websites are stupid
        tor-browser-bundle-bin # Tor browser
        libreoffice # Office suite
        kdiff3 # Well know diffing tool
        gparted # GUI partition manager
        dbeaver-bin # SQL database GUI
        filezilla # Free FTP/FTPS/SFTP software
        gimp # Photoshop alternative
        iwgtk # WiFi GUI for "Intel Wireless Daemon"
        winbox4
      ]
      ++ (
        if config.programs.rbw.enable then
          [
            pkgs.rofi-rbw-wayland
          ]
        else
          [ ]
      );
  };
}
