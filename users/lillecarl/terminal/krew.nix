{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.krew
  ];

  xdg.configFile."krew/bin/kubectl-krew" = {
    source = lib.getExe pkgs.krew;
    executable = true;
  };
}
