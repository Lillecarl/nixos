{ pkgs
, inputs
, ...
}: {
  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";

    lfs.enable = true;
    delta.enable = true;

    signing = {
      key = "3916387439FCDA33";
      signByDefault = false;
    };

    aliases = {
      root = "rev-parse --show-toplevel";
      # $1 = which branch to merge into
      # $N = extra arguments
      # leading exclamation mark(!) makes git run shell commands
      mergepush = builtins.replaceStrings [ "\n" ] [ " " ] ''
        !test $# -gt 0 || exit 1;
        git push
        ''${@:2}
        -o merge_request.create
        -o merge_request.target=$1
        -o merge_request.merge_when_pipeline_succeeds
        -o merge_request.remove_source_branch
        #
      ''; # The final hash prevents git from appending arguments to the command
    };

    extraConfig = {
      push.autoSetupRemote = true;
    };
  };

  programs.gitui = {
    enable = true;
    theme = builtins.readFile "${inputs.catppuccin-gitui}/theme/mocha.ron";
  };

  home.packages = [
    pkgs.tig # TUI tool to see branches and commit log graph
    pkgs.glab # Gitlab CLI
  ];
}
