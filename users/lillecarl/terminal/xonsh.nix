{
  config,
  lib,
  ...
}:
{
  programs.xonsh = {
    enable = true;
    extraConfig = # xonsh
      ''
        execx($(${lib.getExe config.programs.starship.package} init xonsh))
      '';
  };
}
