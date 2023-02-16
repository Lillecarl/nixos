{ pkgs
, lib
, ...
}:
pkgs.makeDesktopItem {
  name = "slack";
  desktopName = "Slack";
  icon = "${pkgs.slack}/share/pixmaps/slack.png";
  mimeTypes = lib.splitString ";" "x-scheme-handler/slack";
  exec = "${pkgs.slack}/bin/slack --ozone-platform=wayland %U";
}
