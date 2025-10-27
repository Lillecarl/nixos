{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "git";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      settings = {
        user.email = "git@${config.ps.info.emailDomain}";
        user.name = config.ps.info.name;
        alias = {
          # leading exclamation mark(!) makes git run shell commands
          root = "rev-parse --show-toplevel";
        };
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

      lfs.enable = config.ps.terminal.mode == "fat";

      signing = {
        key = "3916387439FCDA33";
        signByDefault = false;
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
          (work "~/Work")
        ];
    };

    programs.gitui = {
      enable = true;
    };

    home.packages =
      if config.ps.terminal.mode == "fat" then
        with pkgs;
        [
          gh # GitHub CLI
          glab # Gitlab CLI

          git-imerge # Interactive merge, rebase
          git-open # Open git repo in browser
          git-instafix # Pick staged changes into previous commits
          tig # TUI tool to see branches and commit log graph

          # untested
          git-gone # Remove stale branches
          git-trim # Remove merged branches
          git-sync # Sync
          git-fire # push everything
          git-recent
          git-absorb
          git-ignore
          gitflow
        ]
      else
        [ ];

    xdg.configFile."git/work".text = lib.generators.toGitINI {
      user.name = config.ps.info.name;
      user.email = config.ps.info.emailWork;
    };
  };
}
