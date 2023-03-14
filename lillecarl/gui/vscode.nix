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
      "files.insertFinalNewline" = true;
      "telemetry.telemetryLevel" = "off";
      "keyboard.dispatch" = "keyCode";
      "redhat.telemetry.enabled" = false;
      "workbench.startupEditor" = "none";
      "editor.inlineSuggest.enabled" = true;
      "update.mode" = "none";
      "files.autoSave" = "onFocusChange";
      "files.autoSaveDelay" = 500;
      "editor.insertSpaces" = true;
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
      "vim.enableNeovim" = true;
      # Executable path configurations
      "terraform.languageServer.path" = "${pkgs.terraform-ls}/bin/terraform-ls";
      "pylsp.executable" = "${pkgs.python3.pkgs.python-lsp-server}/bin/pylsp";
      "vscode-kubernetes.kubectl-path" = "${pkgs.kubectl}/bin/kubectl";
      "vscode-kubernetes.helm-path" = "${pkgs.kubernetes-helm}/bin/helm";
      "ansible.ansible.path" = "${pkgs.ansible}/bin/ansible";
      "vim.neovimPath" = "${pkgs.neovim}/bin/nvim";
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
    };
  };
}
