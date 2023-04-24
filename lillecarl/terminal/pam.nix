{ config
, pkgs
, inputs
, ...
}: {
  pam = {
    sessionVariables = rec {
      EDITOR = "${pkgs.neovim}/bin/nvim";
      VISUAL = "${pkgs.neovim}/bin/nvim";
      PAGER = "${pkgs.moar}/bin/moar";
      # Git configuration (For sending over SSH)
      GIT_AUTHOR_NAME = "Carl Hjerpe";
      GIT_AUTHOR_EMAIL = "git@lillecarl.com";
      GIT_COMMITTER_NAME = GIT_AUTHOR_NAME;
      GIT_COMMITTER_EMAIL = GIT_AUTHOR_EMAIL;
      EMAIL = GIT_AUTHOR_EMAIL;
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
      XAUTHORITY = "\"$XDG_RUNTIME_DIR\"/Xauthority";
    };
  };
}
