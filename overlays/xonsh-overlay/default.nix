final: prev: {
  xonsh =
    let
      python3Packages = final.python310.pkgs;
    in
    (prev.xonsh.override { python3Packages = prev.python310.pkgs; }).overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.flatten [
        (with python3Packages; with prev.pkgs; [
          xonsh-direnv
          xontrib-argcomplete
          xontrib-output-search
          xontrib-fzf-widgets
          xontrib-ssh-agent
          xontrib-sh
          lazyasd
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
