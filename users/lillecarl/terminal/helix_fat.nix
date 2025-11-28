{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "helix";
  cfg = config.ps.${modName};
in
{
  config = lib.mkIf (cfg.enable && config.ps.editors.mode == "fat") {
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
        pkgs.stylua
        pkgs.bash-language-server
        pkgs.dockerfile-language-server
        pkgs.fish-lsp
        pkgs.helix-gpt
        pkgs.nixd
        pkgs.nixfmt-rfc-style
        pkgs.pyright
        pkgs.python3Packages.python-lsp-server
        pkgs.rust-analyzer
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.taplo
        pkgs.terraform-ls
        pkgs.vscode-langservers-extracted
        pkgs.wl-clipboard
        pkgs.yaml-language-server
        # Add opentofu as terraform to Helix PATH
        # Required because terraform-ls uses the terraform binary from path
        # to format documents.
        (pkgs.stdenv.mkDerivation {
          name = "terratofu";
          phases = "installPhase";
          installPhase = ''
            mkdir -p $out/bin
            ln -s ${pkgs.opentofu}/bin/tofu $out/bin/terraform
          '';
        })
      ];

      languages = {
        # language-server.nixd = {
        #   config.formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
        # };
        language-server.nil = {
          config = {
            nil = {
              formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
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
        language-server.ruff = {
          command = lib.getExe pkgs.ruff;
          args = [ "server" ];
        };
        language = [
          {
            name = "nix";
            language-servers = [
              "nixd"
            ];
          }
          {
            name = "fish";
            language-servers = [
              "fish-lsp"
            ];
          }
          {
            name = "toml";
            language-servers = [
              "taplo"
            ];
          }
          {
            name = "python";
            language-servers = [
              "pyright"
              "ruff"
            ];
          }
          # { name = "lua"; language-servers = [ "luals" "gpt" ]; }
          # { name = "yaml"; language-servers = [ "yamlls" "gpt" ]; }
        ];
      };
    };
  };
}
