{ pkgs
, ...
}:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      catppuccin
    ];

    extraConfig = ''
      source-file ~/.config/tmux/linked.conf"}
    '';
  };
}
