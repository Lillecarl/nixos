_:
{
  programs.readline = {
    enable = true;

    extraConfig = ''
    '';

    variables = {
      editing-mode = "vi";
      keymap = "vi-command";
      show-mode-in-prompt = "on";
      vi-ins-mode-string = "\\1\\e[6 q\\2";
      vi-cmd-mode-string = "\\1\\e[2 q\\2";
    };
  };
}
