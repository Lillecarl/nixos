{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    package = pkgs.vscode;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (
      builtins.fromJSON (
        builtins.readFile ../../pkgs/vscodeExtensions.json));

    userSettings = {
      "editor.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "editor.inlineSuggest.enabled" = true;
      "editor.insertSpaces" = true;
      "files.autoSave" = "onFocusChange";
      "files.autoSaveDelay" = 500;
      "files.insertFinalNewline" = true;
      "keyboard.dispatch" = "keyCode";
      "redhat.telemetry.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "update.mode" = "none";
      "workbench.startupEditor" = "none";
      "vim.enableNeovim" = true;

      # Executable path configurations
      "ansible.ansible.path" = "${pkgs.ansible}/bin/ansible";
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
      "pylsp.executable" = "${pkgs.python3.pkgs.python-lsp-server}/bin/pylsp";
      "terraform.languageServer.path" = "${pkgs.terraform-ls}/bin/terraform-ls";
      "vim.neovimPath" = "${pkgs.neovim}/bin/nvim";
      "vscode-kubernetes.helm-path" = "${pkgs.kubernetes-helm}/bin/helm";
      "vscode-kubernetes.kubectl-path" = "${pkgs.kubectl}/bin/kubectl";

      "[tf]" = {
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
      };
      "shebang.associations" = [
        {
          "pattern" = "^#!py$";
          "language" = "python";
        }
      ];
    };
  };
}
