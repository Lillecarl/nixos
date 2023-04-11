{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      lillecarl = {
        id = 0;
        isDefault = true;
      };
    };
  };
}
