{ lib, config, ... }:
{
  # Set variables for shells
  home.sessionVariables = {
    FLAKE = flakeloc;
    HOST = config.sd.hostname;
  };
  # Set default variables for systemd user units
  systemd.user.sessionVariables = {
    FLAKE = flakeloc;
    HOST = config.sd.hostname;
  };

