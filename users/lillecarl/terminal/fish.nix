{ lib, config, pkgs, ... }:
{
  programs.starship.enableFishIntegration = config.ps.terminal.enable;

  programs.fish = lib.mkIf config.ps.terminal.enable {
    enable = true;

    plugins = with pkgs.fishPlugins; [
      {
        name = "done";
        inherit (done) src;
      }
    ];

    interactiveShellInit = /* fish */ ''
      ${lib.getExe pkgs.zoxide} init fish | source
      ${pkgs.thefuck}/bin/thefuck --alias | source
      #source $XDG_RUNTIME_DIR/agenix/sourcegraph
      #source $XDG_RUNTIME_DIR/agenix/copilot
    '';

    shellInit = ''
    '';
    shellInitLast = ''
      for line in $(find ${config.xdg.configHome}/fish/final/*.fish)
          source $line || echo "Sourcing $line failed"
      end
    '';
  };
}
