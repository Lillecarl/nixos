{ pkgs
, bp
, ...
}:
let
  pythonWithAnsible = pkgs.python3.withPackages (ps: with ps; [
    ansible
  ]);
in
{
  programs.vscode = {
    enable = true;

    package = pkgs.vscodium;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace
      (builtins.fromJSON
        (builtins.readFile ../../pkgs/vscodeExtensions.json)
      ) ++
    (with pkgs.vscode-marketplace; [
      pkgs.vscode-marketplace."4ops".terraform
      bbenoist.nix
      davidhewitt.shebang-language-associator
      editorconfig.editorconfig
      github.copilot
      hashicorp.terraform
      llvm-vs-code-extensions.vscode-clangd
      mkhl.direnv
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cpptools
      ms-vsliveshare.vsliveshare
      redhat.ansible
      redhat.vscode-yaml
      vscodevim.vim
    ]);

    userSettings = {
      "C_Cpp.intelliSenseEngine" = "disabled";
      "editor.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "editor.inlineSuggest.enabled" = true;
      "editor.insertSpaces" = true;
      "files.autoSave" = "onFocusChange";
      "files.autoSaveDelay" = 500;
      "files.eol" = "\n";
      "files.insertFinalNewline" = true;
      "keyboard.dispatch" = "keyCode";
      "password-store" = "gnome-libsecret";
      "redhat.telemetry.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "update.mode" = "none";
      "vim.enableNeovim" = true;
      "window.titleBarStyle" = "custom";
      "workbench.startupEditor" = "none";

      # Executable path configurations
      "ansible.ansible.path" = bp pkgs.ansible;
      "ansible.python.interpreterPath" = pythonWithAnsible;
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
      "pylsp.executable" = bp pkgs.python3.pkgs.python-lsp-server;
      "terraform.languageServer.path" = bp pkgs.terraform-ls;
      "vim.neovimPath" = bp pkgs.neovim;
      "vscode-kubernetes.helm-path" = bp pkgs.kubernetes-helm;
      "vscode-kubernetes.kubectl-path" = bp pkgs.kubectl;

      "[tf]" = {
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
      };

      "shebang.associations" = [
        {
          "pattern" = "^#!py$"; # Required for saltstack python templates
          "language" = "python";
        }
      ];
    };
  };
}
