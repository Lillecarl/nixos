{ lib, config, pkgs, ... }:
{
  programs.helix = lib.mkIf (config.ps.editors.enable  && config.ps.editors.mode == "fat") {
    languages = {
      language-server.nil = {
        command = lib.getExe pkgs.nil;
        config.nil = {
          formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
          nix.flake.autoEvalInputs = true;
        };
      };
      language-server.gpt = {
        command = "${lib.getExe pkgs.helix-gpt} --handler copilot";
      };
      language-server.luals = {
        command = "${lib.getExe pkgs.lua-language-server}";
      };
      language-server.pylsp = {
        command = lib.getExe pkgs.python3Packages.python-lsp-server;
      };
      language-server.yamlls = {
        command = lib.getExe pkgs.yaml-language-server;
      };

      language = [
        { name = "nix"; language-servers = [ "nil" "gpt" ]; }
        { name = "python"; language-servers = [ "pylsp" "gpt" ]; }
        { name = "lua"; language-servers = [ "luals" "gpt" ]; }
        { name = "yaml"; language-servers = [ "yamlls" "gpt" ]; }
      ];
    };
  };
}
