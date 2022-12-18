final: prev: {
  xonsh =
    (prev.xonsh.override { python3Packages = prev.python310.pkgs; }).overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.flatten [
        (with final.python310.pkgs; with final.pkgs; [
          xonsh-direnv
          xontrib-argcomplete
          xontrib-output-search
          xontrib-fzf-widgets
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
