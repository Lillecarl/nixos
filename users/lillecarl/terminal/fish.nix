{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "fish";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.atuin.enableFishIntegration = true;
    programs.starship.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      package = config.lib.pspkgs.fish4;

      generateCompletions = config.ps.terminal.mode == "fat";

      plugins = with pkgs.fishPlugins; [
        {
          name = "done";
          inherit (done) src;
        }
      ];

      interactiveShellInit = # fish
        ''
          ${lib.getExe pkgs.zoxide} init fish | source
          ${pkgs.thefuck}/bin/thefuck --alias | source
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
  };
}
