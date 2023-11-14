{ pkgs
, ...
}:
let
  pythonWithAnsible = pkgs.python3.withPackages (ps: with ps; [
    ansible
  ]);

  vscodeWithBin = pkgs.symlinkJoin {
    name = "vscode-joined";
    inherit (pkgs.vscode) pname version;

    paths = [
      pkgs.vscode
      pythonWithAnsible
    ];
  };
in
{
  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    package = vscodeWithBin;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace
      (
        (builtins.fromJSON
          (builtins.readFile ../../pkgs/vscodeExtensions.json)
        )
      ) ++
    (with pkgs.vscode-marketplace; [
      pkgs.vscode-marketplace."4ops".terraform
      bbenoist.nix
      editorconfig.editorconfig
      github.copilot
      hashicorp.terraform
      llvm-vs-code-extensions.vscode-clangd
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cpptools
      ms-vsliveshare.vsliveshare
      redhat.vscode-yaml
      vscodevim.vim
      davidhewitt.shebang-language-associator
      joaompinto.vscode-graphviz
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      redhat.ansible
    ]);

    userSettings = {
      "password-store" = "gnome-libsecret";
      "editor.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "editor.inlineSuggest.enabled" = true;
      "editor.insertSpaces" = true;
      "files.autoSave" = "onFocusChange";
      "files.autoSaveDelay" = 500;
      "files.eol" = "\n";
      "files.insertFinalNewline" = true;
      "keyboard.dispatch" = "keyCode";
      "redhat.telemetry.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontFamily" = "'Hack Nerd Font', 'monospace', monospace";
      "update.mode" = "none";
      "vim.enableNeovim" = true;
      "window.titleBarStyle" = "custom";
      "workbench.startupEditor" = "none";

      # Executable path configurations
      "ansible.ansible.path" = "${pkgs.ansible}/bin/ansible";
      "ansible.python.interpreterPath" = pythonWithAnsible;
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
          "pattern" = "^#!py$"; # Required for saltstack python templates
          "language" = "python";
        }
      ];
    };
  };
}
