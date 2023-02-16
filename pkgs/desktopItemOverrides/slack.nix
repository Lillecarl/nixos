{ pkgs
, lib
, ...
}:
pkgs.makeDesktopItem {
  name = "slack";
  desktopName = "Slack";
  icon = "${pkgs.slack-dark}/share/pixmaps/slack.png";
  mimeTypes = lib.splitString ";" "x-scheme-handler/slack";
  exec = "${pkgs.slack-dark}/bin/slack --ozone-platform=wayland %U";
}
