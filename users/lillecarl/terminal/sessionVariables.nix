{
  lib,
  config,
  repositoryLocation,
  nixosConfig ? { },
  ...
}:
{
  # Set variables for shells
  home.sessionVariables = {
    FLAKE = repositoryLocation;
    HOST = config.ps.hostname;
    CONTAINERD_ADDRESS = nixosConfig.environment.variables.CONTAINERD_ADDRESS or "";
    CONTAINERD_NAMESPACE = nixosConfig.environment.variables.CONTAINERD_NAMESPACE or "";
  };
  # Set default variables for systemd user units
  systemd.user.sessionVariables = {
    FLAKE = repositoryLocation;
    HOST = config.ps.hostname;
  };
}
