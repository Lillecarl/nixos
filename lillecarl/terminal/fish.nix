{ pkgs
, bp
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
      ${bp pkgs.zoxide} init fish | source
      ${bp pkgs.thefuck} --alias | source
    '';

    shellInit = ''
    '';
  };
}
