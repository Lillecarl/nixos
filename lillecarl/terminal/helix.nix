{ pkgs
, bp
, ...
}:
{
  programs.helix = {
    enable = true;

    languages = {
      language-server = {
        nix-lsp = {
          command = bp pkgs.nil;
          config = {
            languages = { };
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
