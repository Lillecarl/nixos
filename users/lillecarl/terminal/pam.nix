{
  pkgs,
  config,
  lib,
  ...
}:
let
  pager = "less";
in
{
  pam = {
    sessionVariables = {
      # Pager configuration
      PAGER = pager;
      SYSTEMD_PAGER = pager;
      MAN_PAGER = pager;
      GIT_PAGER = pager;
      SYSTEMD_PAGERSECURE = "true";
      # Git configuration (For sending over SSH)
      GIT_AUTHOR_NAME = config.ps.info.name;
      GIT_AUTHOR_EMAIL = "git@${config.ps.info.emailDomain}";
      GIT_COMMITTER_NAME = config.ps.info.name;
      GIT_COMMITTER_EMAIL = "git@${config.ps.info.emailDomain}";
      EMAIL = config.ps.info.emailPrivate;
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
