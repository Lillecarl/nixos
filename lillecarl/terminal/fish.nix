{ pkgs
, config
, flakeloc
, ...
}:
{
  programs.starship.enableFishIntegration = true;

  programs.fish = {
    enable = true;

    plugins =
      (builtins.map
        (
          plug: {
            name = plug.name;
            src = pkgs.fetchFromGitHub plug.src;
          }
        )
        (
          builtins.fromJSON (
            builtins.readFile ./fishPlugins.json
          )
        )
      ) ++ (with pkgs.fishPlugins; [
        {
          name = "done";
          src = done.src;
        }
      ]) ++
      [
      ];

    interactiveShellInit = ''
      source ${config.home.homeDirectory}/.config/fish/*.conf
      ${pkgs.zoxide}/bin/zoxide init fish | source
    '';

    shellInit = ''
    '';
  };
}
