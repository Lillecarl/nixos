{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "distrobox";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.mode == "fat";
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # Enable distrobox
    programs.distrobox.enable = true;
    # distrobox needs Podman
    services.podman.enable = true;
    # Create a link farm with common packages required to get anything
    # in my $HOME going.
    xdg.configFile."distrobox_bin" = {
      source = pkgs.symlinkJoin {
        name = "distrobox_bin";
        paths = with config; [
          pkgs.coreutils
          pkgs.gawk

          nix.package
          programs.atuin.package
          programs.fd.package
          programs.fish.package
          programs.ripgrep.package
          programs.starship.package
          programs.zoxide.package
        ];
      };
    };
  };
}
