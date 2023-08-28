{ pkgs
, config
, flakeloc
, ...
}:
{
  programs.starship.enableFishIntegration = true;

  home.file.".config/fish/conf.d".source = config.lib.file.mkOutOfStoreSymlink "${flakeloc}/lillecarl/terminal/fish";

  programs.fish = {
    enable = true;

    plugins = [
    ];

    interactiveShellInit = ''
      ${pkgs.starship}/bin/starship init fish | source
      source ${config.home.homeDirectory}/.config/fish/conf.d/*.conf
    '';

    shellInit = ''
    '';
  };
}
