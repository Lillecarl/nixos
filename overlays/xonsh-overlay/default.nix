{ pkgs
, lib
, xonsh-direnv
, xontrib-argcomplete
, xontrib-output-search
, xontrib-fzf-widgets
, xontrib-ssh-agent
, xontrib-sh
}:

final: prev: {
  xonsh =
    let
      python3Packages = final.python310.pkgs;
    in
    (prev.xonsh.override { python3Packages = pkgs.python310.pkgs; }).overrideAttrs (old: {
      propagatedBuildInputs = lib.flatten [
        (with python3Packages; [
          xonsh-direnv
          xontrib-argcomplete
          xontrib-output-search
          xontrib-fzf-widgets
          xontrib-ssh-agent
          xontrib-sh
          pyyaml
          psutil
          jinja2
        ])
        (old.propagatedBuildInputs or [ ])
      ];
      checkInputs = [ ];
      checkPhase = "";
      pytestcheckPhase = "";
    });
}
