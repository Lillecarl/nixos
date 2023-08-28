{ pkgs
, ...
}:
{
  programs.starship.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    plugins = with pkgs.fishPlugins; [
      z
      fzf
    ];

    interactiveShellInit = ''
    '';

    shellInit = ''
    '';
  };
}
