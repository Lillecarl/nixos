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
    # Maybe configure keyconfig at some point, but the gitui keybinding engine doesn't
    # seem to support multiple keys for the same action, there's also no context for keybindings
    # to use to have the same key o different things in different views
  };
}
