{ pkgs
, lib
, ...
}:
{
  programs.helix = {
    enable = true;

    languages = {
      language-server = {
        nix = {
          command = lib.getExe pkgs.nil;
          config.nil = {
            formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
            nix.flake.autoEvalInputs = true;
          };
        };
      };

      language = [
        { name = "nix"; language-servers = [ "nix" ]; }
      ];
    };
  };
}
