{ config
, lib
, pkgs
, self
, ...
}:
let
  cfg = config.carl.gui.vscode;
  pythonWithAnsible = pkgs.python3.withPackages (ps: with ps; [
    ansible
  ]);
in
{
  options.carl.gui.vscode = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;

      package = pkgs.vscodium;

      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;

      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace
        (builtins.fromJSON
          (builtins.readFile "${self}/pkgs/vscodeExtensions.json")
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
        asvetliakov.vscode-neovim
      ]);

      userSettings = {
        "C_Cpp.intelliSenseEngine" = "disabled";
        "editor.inlineSuggest.enabled" = true;
        "editor.insertSpaces" = true;
        "editor.formatOnSave" = true;
        "files.autoSave" = "onFocusChange";
        "files.autoSaveDelay" = 500;
        "files.eol" = "\n";
        "files.insertFinalNewline" = true;
        "keyboard.dispatch" = "keyCode";
        "password-store" = "gnome-libsecret";
        "window.titleBarStyle" = "custom";
        "workbench.startupEditor" = "none";
        "git.openRepositoryInParentFolders" = "never";

        # updates and telemetry
        "redhat.telemetry.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";

        # direnv
        "direnv.restart.automatic" = true;
        "direnv.path.executable" = lib.getExe pkgs.direnv;

        # vim
        "vscode-neovim.neovimExecutablePaths.linux" = lib.getExe pkgs.neovim;
        "extensions.experimental.affinity" = {
          "asvetliakov.vscode-neovim" = 1;
        };

        # Executable path configurations
        "ansible.ansible.path" = "${pkgs.ansible}/bin/ansible";
        "ansible.python.interpreterPath" = pythonWithAnsible;
        "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
        "pylsp.executable" = lib.getExe pkgs.python3.pkgs.python-lsp-server;
        "terraform.languageServer.path" = "${pkgs.terraform-ls}/bin/terraform-ls";
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
  };
}
