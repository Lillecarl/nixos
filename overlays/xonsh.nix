final: prev: {
  xonsh =
    let
      python3Packages = prev.python3.pkgs;
    in
    (prev.xonsh.override { inherit python3Packages; }).overrideAttrs (old: {
      propagatedBuildInputs = prev.lib.flatten [
        (with python3Packages; [
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
