{ pkgs
, bp
, ...
}:
let
  pager = bp pkgs.nvimpager;
in
{
  pam = {
    sessionVariables = rec {
      # Pager configuration
      PAGER = pager;
      SYSTEMD_PAGER = pager;
      MAN_PAGER = pager;
      GIT_PAGER = pager;
      SYSTEMD_PAGERSECURE = "true";
      SYSTEMD_COLORS = "true";
      # Git configuration (For sending over SSH)
      GIT_AUTHOR_NAME = "Carl Hjerpe";
      GIT_AUTHOR_EMAIL = "git@lillecarl.com";
      GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
      GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
      EMAIL = GIT_AUTHOR_EMAIL;
      NIXPKGS_ALLOW_UNFREE = 1;
      NIX_AUTO_RUN = 1;
    };
  };
}
