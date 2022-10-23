final: prev: {
  _dontExport = true;

  xonsh =
    let
      python3Packages = prev.python3.pkgs;
    in
    (prev.xonsh.override { inherit python3Packages; }).overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.flatten [
        (with prev.pkgs; with prev.python3.pkgs; [
          xonsh-direnv
          xontrib-argcomplete
          xontrib-output-search
          xontrib-fzf-widgets
          pyyaml
          prev.python3.pkgs.psutil
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
