{ pkgs
, config
, lib
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
            inherit (plug) name;
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
          inherit (done) src;
        }
      ]);

    interactiveShellInit = /* fish */ ''
      ${lib.getExe pkgs.zoxide} init fish | source
      ${pkgs.thefuck}/bin/fuck --alias | source
    '';

    shellInit = ''
    '';
    shellInitLast = ''
      source ${config.xdg.configHome}/fish/conf.d.after/*.fish
    '';
  };
}
