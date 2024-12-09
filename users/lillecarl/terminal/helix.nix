{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.helix = lib.mkIf config.ps.editors.enable {
    enable = config.ps.editors.enable;
    defaultEditor = true;
    #package = (builtins.getFlake "/home/lillecarl/Code/helix").packages.${pkgs.system}.helix;
    # If we have a Helix built with "cargo build" in $HOME/Code/helix we write a
    # shell script that calls that one rather than using one from nixpkgs.
    package =
      let
        repo = "/home/lillecarl/Code/helix";
        runtime = "${repo}/runtime";
        exe = "${repo}/target/debug/hx";
      in
      if builtins.pathExists exe && builtins.pathExists runtime then
        pkgs.writeScriptBin "hx"
          # bash
          ''
            #! ${pkgs.runtimeShell}
            # Tells Helix where to look for runtime code (tree-sitter
            # grammars, themes and stuff)
            export HELIX_RUNTIME="${runtime}" 
            exec ${exe} "$@"
          ''
      else
        pkgs.helix;

    settings = {
      theme = if config.ps.terminal.true-color then "catppuccin_mocha" else "default";
      editor = {
        true-color = config.ps.terminal.true-color;
        indent-guides.render = true;
        rulers = [ 80 ];
        bufferline = "always";
        color-modes = true;
      };
      keys = {
        normal = {
          "C-s" = ":w";
          "X" = "extend_line_above";
        };
        insert = {
          "C-s" = ":w";
          "C-space" = "completion";
        };
      };
    };
  };
}
