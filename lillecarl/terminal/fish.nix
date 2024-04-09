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
      ${pkgs.thefuck}/bin/thefuck --alias | source
    '';

    shellInit = ''
    '';
    shellInitLast = ''
      for line in $(find ${config.xdg.configHome}/fish/conf.d.after/*.fish)
          source $line || echo "Sourcing $line failed"
      end
    '';
  };
}
