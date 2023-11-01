{ config
, pkgs
, inputs
, ...
}: {
  pam = {
    sessionVariables = rec {
      VISUAL = "${pkgs.neovim}/bin/nvim";
      PAGER = "${pkgs.moar}/bin/moar";
      # Git configuration (For sending over SSH)
      GIT_AUTHOR_NAME = "Carl Hjerpe";
      GIT_AUTHOR_EMAIL = "git@lillecarl.com";
      GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
      GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
      EMAIL = GIT_AUTHOR_EMAIL;
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
