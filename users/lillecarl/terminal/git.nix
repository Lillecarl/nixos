{ pkgs
, config
, lib
, ...
}:
{
  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";

    lfs.enable = true;

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

    includes =
      let
        work = path: {
          condition = "gitdir:${path}/";
          path = config.xdg.configFile."git/work".source;
        };
      in
      [
        (work "~/Code/SE")
        (work "~/Work")
      ];

    extraConfig = {
      advice.diverging = false;
      branch.sort = "-committerdate";
      column.ui = "auto";
      core.fsmonitor = true;
      core.ignorecase = false;
      core.untrackedcache = true;
      fetch.recurseSubmodules = true;
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      rebase.updateRefs = true;
      rerere.enable = true;
      tag.sort = "version:refname";
      trim.bases = "master,main,develop";
    };
  };

  programs.gitui = {
    enable = true;
  };

  home.packages = [
    pkgs.gh # GitHub CLI
    pkgs.glab # Gitlab CLI

    pkgs.git-imerge # Interactive merge, rebase
    pkgs.git-open # Open git repo in browser
    pkgs.tig # TUI tool to see branches and commit log graph

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

  xdg.configFile."git/work".text = lib.generators.toGitINI {
    user.name = "Carl Hjerpe";
    user.email = "carl.hjerpe@helicon.ai";
  };
}
