{
  lib,
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."distrobox_bin" = lib.mkIf config.ps.terminal.enable {
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
}
