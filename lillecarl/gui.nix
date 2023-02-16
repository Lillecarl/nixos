{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [ rofimoji rofi-rbw ];
  };

  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    package = pkgs.vscode-joined;

    extensions = with pkgs.vscode-extensions; [
      # Upstream packaged
      vscodevim.vim
      bbenoist.nix
      # Own packaging
      EditorConfig.EditorConfig
      HashiCorp.terraform
      jnoortheen.xonsh
      joaompinto.vscode-graphviz
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.isort
      ms-python.python        
      ms-python.vscode-pylance
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      redhat.ansible
      redhat.vscode-yaml
    ];

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
      "terraform.languageServer.path" = "${pkgs.terraform-ls}/bin/terraform-ls";
      "pylsp.executable" = "${pkgs.python3.pkgs.python-lsp-server}/bin/pylsp";
    };
  };

  home.packages = with pkgs; [
    # Temporary
    wofi # Wayland rofi?

    # Desktop item overrides
    (hiPrio vscode-wayland)
    (hiPrio slack-wayland)
    (hiPrio brave-wayland)

    # Chat apps
    element-desktop # Element Slack app
    teams # Microsoft Teams collaboration suite (Electron)
    discord # Gaming chat application
    zoom # Meetings application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    #vlc # VLC sucks in comparision to MPV
  ];
}
