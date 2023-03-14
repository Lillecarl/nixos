{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      lillecarl = {
        id = 1337;
        isDefault = true;
      };
      empty = {
        id = 321;
      };
    };
  };
}
