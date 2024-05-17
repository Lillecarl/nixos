{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui;
in
{
  options.carl.gui.packages = with lib; mkOption {
    type = types.listOf types.package;
    default = [ ];
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ferdium # Web multiplexer
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
      kleopatra # GUI for PGP
      gpa # GUI for PGP
      google-chrome # Only use this when websites are stupid
      webcord-vencord # Discord client
      tor-browser-bundle-bin # Tor browser
      libreoffice # Office suite
      adoptopenjdk-icedtea-web # Java Web Start
      kdiff3 # Well know diffing tool
      ark # Archiving tool
      gparted # GUI partition manager
      dbeaver # SQL database GUI
      filezilla # Free FTP/FTPS/SFTP software
      qbittorrent # OpenSource Qt Bittorrent client
      okular # PDF viewer
      gimp # Photoshop alternative
      webcamoid # Webcam application
      ghostwriter # Markdown editor (live renderer)
    ] ++ (
      if config.programs.rbw.enable then [
        pkgs.rofi-rbw-wayland
      ] else [ ]
    ) ++
    cfg.packages;
  };
}
