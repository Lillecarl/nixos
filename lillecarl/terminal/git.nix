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
      mergepush = builtins.replaceStrings [ "\n" ] [ " " ] /* bash */ ''
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

    ignores = [
      ".privrc"
    ];

    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.gitui = {
    enable = true;
    theme = builtins.readFile "${inputs.catppuccin-gitui}/theme/mocha.ron";
  };

  home.packages = [
    pkgs.tig # TUI tool to see branches and commit log graph
    pkgs.glab # Gitlab CLI
    pkgs.git-open # Open git repo in browser
    pkgs.git-imerge # Interactive merge, rebase
    # untested
    pkgs.git-up # Update git repo
    pkgs.git-gone # Remove stale branches
    pkgs.git-trim # Remove merged branches
    pkgs.git-sync # Sync
    pkgs.git-fire # push everything
    pkgs.git-recent
    pkgs.git-absorb
    pkgs.git-ignore
    pkgs.gitflow
  ];
}
