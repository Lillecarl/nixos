{ pkgs
, lib
, ...
}:
pkgs.makeDesktopItem {
  name = "code";
  desktopName = "Visual Studio Code";
  icon = "code";
  mimeTypes = lib.splitString ";" "text/plain;inode/directory";
  exec = "${pkgs.vscode}/bin/code --ozone-platform=wayland %U";
}
