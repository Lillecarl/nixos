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
      userName = config.ps.info.name;
      userEmail = "git@${config.ps.info.emailDomain}";

      lfs.enable = config.ps.terminal.mode == "fat";

      signing = {
        key = "3916387439FCDA33";
        signByDefault = false;
      };

      aliases = {
        # leading exclamation mark(!) makes git run shell commands
        root = "rev-parse --show-toplevel";
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

    home.packages =
      if config.ps.terminal.mode == "fat" then
        [
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
        ]
      else
        [ ];

    xdg.configFile."git/work".text = lib.generators.toGitINI {
      user.name = config.ps.info.name;
      user.email = config.ps.info.emailWork;
    };
  };
}
