{ ...
}: {
  imports = [
    ../../modules/hm/xonsh
  ];

  programs.xonsh = {
    enable = true;

    rcDir = ../dotfiles/.config/xonsh/rc.d;
    extraConfig = builtins.readFile ../dotfiles/.config/xonsh/rc.xsh;
    enableBashCompletion = true;
  };
}
