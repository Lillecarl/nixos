{ pkgs, ... }:
{
  programs.helix = {
    enable = true;

    languages = {
      language-server = {
        nix-lsp = {
          command = "${pkgs.nil}/bin/nil";
          config = {
            languages = {};
          };
        };
      };

      language = [
        {
          name = "nix";
        }
      ];
    };
  };
}
