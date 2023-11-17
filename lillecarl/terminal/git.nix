{ config
, pkgs
, inputs
, ...
}: {
  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";
    lfs.enable = true;

    signing = {
      key = "3916387439FCDA33";
      signByDefault = false;
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
  ];
}
