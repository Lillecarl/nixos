{ pkgs
, config
, flakeloc
, ...
}:
let
  getHomeFilePath = path: config.home.homeDirectory + config.home.file.${path}.target;
  mkOutOfStoreAbsLink = path: config.lib.file.mkOutOfStoreSymlink "${flakeloc}/${path}";
in
{
  home.file.".config/tmux/linked.conf".source = mkOutOfStoreAbsLink "lillecarl/terminal/tmux.conf";

  programs.tmux = {
    enable = true;

    clock24 = true;
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      catppuccin
    ];

    extraConfig = ''
      source-file ${getHomeFilePath ".config/tmux/linked.conf"}
    '';
  };
}
