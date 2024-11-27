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

    # Prepend some Nix & HM paths if they're not already there.
    # Required when using fish as login shell in Crostini.
    shellInit =
      let
        paths = [
          "/nix/var/nix/profiles/default/bin"
          "${config.home.homeDirectory}/.nix-profile/bin"
          "${config.home.homeDirectory}/.local/bin"
        ];
        pathsStr = lib.pipe paths [
          (paths: builtins.map (path: "contains ${path} $PATH || set --prepend PATH ${path}") paths)
          (lines: lib.concatLines lines)
        ];
      in
      ''
        ${pathsStr}
      '';
    shellInitLast = ''
      for line in $(find ${config.xdg.configHome}/fish/final/*.fish)
          source $line || echo "Sourcing $line failed"
      end
    '';
  };
}
