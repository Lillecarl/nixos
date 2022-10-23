final: prev: {
  _dontExport = true;

  xonsh =
    (prev.xonsh.override { inherit (prev.python3.pkgs); }).overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.flatten [
        (with prev.pkgs; with prev.python3.pkgs; [
          xonsh-direnv
          xontrib-argcomplete
          xontrib-output-search
          xontrib-fzf-widgets
          pyyaml
          psutil
          jinja2
        ])
        (old.propagatedBuildInputs or [ ])
      ];
      checkInputs = [ ];
      checkPhase = "";
      pytestcheckPhase = "";
    }
  );
}
