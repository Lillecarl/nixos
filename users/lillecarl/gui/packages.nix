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
        spotify # Music player
        bitwarden # Password manager
        xfce.ristretto # Image viewer
        pcmanfm # File manager
        neovide # Neovim GUI
        d-spy # GUI browser for dbus
        mpv # Video player
        vlc # VLC sucks in comparison to MPV
        wev # Like xev but for wayland, displays which keys you're pressing
        gitg # Git GUI for viewing branches
        signal-desktop # Signal messenger, useful to copy-paste stuff to your phone
        kdePackages.kleopatra # GUI for PGP
        gpa # GUI for PGP
        google-chrome # Only use this when websites are stupid
        webcord-vencord # Discord client
        tor-browser-bundle-bin # Tor browser
        libreoffice # Office suite
        adoptopenjdk-icedtea-web # Java Web Start
        kdiff3 # Well know diffing tool
        gparted # GUI partition manager
        dbeaver-bin # SQL database GUI
        filezilla # Free FTP/FTPS/SFTP software
        qbittorrent # OpenSource Qt Bittorrent client
        gimp # Photoshop alternative
        webcamoid # Webcam application
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
