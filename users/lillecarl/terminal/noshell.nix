{ pkgs, lib, ... }: {
  xdg.configFile."shell".source = lib.getExe pkgs.fish;
}
