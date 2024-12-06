{
  lib,
  config,
  flakeloc,
  ...
}:
{
  # Set variables for shells
  home.sessionVariables = {
    FLAKE = flakeloc;
    HOST = config.ps.hostname;
  };
  # Set default variables for systemd user units
  systemd.user.sessionVariables = {
    FLAKE = flakeloc;
    HOST = config.ps.hostname;
  };
}
