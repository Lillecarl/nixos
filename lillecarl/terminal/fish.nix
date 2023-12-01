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
      ${pkgs.zoxide}/bin/zoxide init fish | source
      ${pkgs.thefuck}/bin/thefuck --alias | source
    '';

    shellInit = ''
    '';
  };
}
