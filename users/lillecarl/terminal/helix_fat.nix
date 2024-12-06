{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.ps.editors.enable && config.ps.editors.mode == "fat") {
    programs.helix = {
      settings = {
        editor = {
          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };
      extraPackages = [
        pkgs.ansible-language-server
        pkgs.bash-language-server
        pkgs.dockerfile-language-server-nodejs
        pkgs.fish-lsp
        pkgs.helix-gpt
        pkgs.nil
        pkgs.nixd
        pkgs.nixpkgs-fmt
        pkgs.pyright
        pkgs.python3Packages.python-lsp-server
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.taplo
        pkgs.terraform-ls
        pkgs.vscode-langservers-extracted
        pkgs.wl-clipboard
        pkgs.yaml-language-server
      ];

      languages = {
        language-server.nil = {
          config = {
            nil = {
              formatting.command = [ "nixpkgs-fmt" ];
            };
          };
        };
        language-server.gpt = {
          command = "helix-gpt";
          args = [
            "--handler"
            "copilot"
          ];
          config = { };
        };
        language-server.fish-lsp = {
          command = "fish-lsp";
          args = [ "start" ];
          config = { };
        };
        language-server.pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
          config = {
            python = {
              analysis = {
                autoSearchPaths = true;
                diagnosticMode = "openFilesOnly";
                useLibraryCodeForTypes = true;
              };
            };
          };
        };
        #language-server.luals = {
        #  command = "${lib.getExe pkgs.lua-language-server}";
        #};
        #language-server.pylsp = {
        #  command = lib.getExe pkgs.python3Packages.python-lsp-server;
        #};
        #language-server.yamlls = {
        #  command = lib.getExe pkgs.yaml-language-server;
        #};

        language = [
          {
            name = "nix";
            language-servers = [
              "nil"
              "gpt"
            ];
            # auto-pairs = {
            #   "'''" = "'''";
            #   "(" = ")";
            #   "[" = "]";
            #   "\"" = "\"";
            #   "`" = "`";
            #   "{" = "}";
            # };
          }
          {
            name = "fish";
            language-servers = [
              "fish-lsp"
              "gpt"
            ];
          }
          {
            name = "toml";
            language-servers = [
              "taplo"
              "gpt"
            ];
          }
          {
            name = "python";
            language-servers = [
              "pyright"
              "gpt"
            ];
          }
          # { name = "lua"; language-servers = [ "luals" "gpt" ]; }
          # { name = "yaml"; language-servers = [ "yamlls" "gpt" ]; }
        ];
      };
    };
  };
}
