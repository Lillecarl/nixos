{ pkgs, lib, ...}:

pkgs.makeDesktopItem {
  name = "brave-browser";
  desktopName = "Brave";
  icon = "brave-browser";
  mimeTypes = lib.splitString ";" "application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns";
  exec = "${pkgs.brave}/bin/brave --ozone-platform=wayland %U";
}
