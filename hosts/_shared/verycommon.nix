{
  lib,
  config,
  pkgs,
  repositoryLocation,
  ...
}:
let
  modName = "verycommon";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.home-manager
    ];

    security.sudo.wheelNeedsPassword = true;

    # Install git
    programs.git.enable = true;

    # XDG Base Directory Specification
    environment.sessionVariables = {
      NODE_HOME = "\${HOME}/.local/node";
      POWERSHELL_TELEMETRY_OPTOUT = "yes"; # No powershell telemetry
      NIXOS_OZONE_WL = "1"; # Use Wayland whenever we can
      PIP_DISABLE_PIP_VERSION_CHECK = "1"; # Disable pip version warnings
      FLAKE = repositoryLocation;
      SYSSTR = pkgs.system;
      HOST = config.networking.hostName;
    };

    services.fstrim.enable = true;

    # Tailscale exit-node & subnet routing fix (asym routing)
    networking.firewall.checkReversePath = "loose";

    # Set your time zone.
    time.timeZone = "Europe/Stockholm";
  };
}
