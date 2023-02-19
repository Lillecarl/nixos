{ config, pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    extensions = [
      { id = "hompjdfbfmmmgflfjdlnkohcplmboaeo"; } # Allow Right-Click
      { id = "occjjkgifpmdgodlplnacmkejpdionan"; } # AutoScroll
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # BitWarden
      { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # ClearURLs
      { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic
      { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # Cookie AutoDelete
      { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
      { id = "omkfmpieigblcllmkgbflkikinpkodlk"; } # enhanced-h264ify
      { id = "fllaojicojecljbmefodhfapmkghcbnh"; } # Google Analytics Opt-out
      { id = "gbiekjoijknlhijdjbaadobpkdhmoebb"; } # IBA Opt-out
      { id = "chklaanhfefbnpoihckbnefhakgolnmc"; } # JSONVue
      { id = "cdglnehniifkbagbbombnjghhcihifij"; } # Kagi for Chrome
      { id = "mmpokgfcmbkfdeibafoafkiijdbfblfg"; } # Merge Windows
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Integrations
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # YouTube SponsorBlock
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "fcphghnknhkimeagdglkljinmpbagone"; } # YouTube Auto HD + FPS
    ];
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
      eamodio.gitlens
      EditorConfig.EditorConfig
      HashiCorp.terraform
      jnoortheen.xonsh
      joaompinto.vscode-graphviz
      llvm-vs-code-extensions.vscode-clangd
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.isort
      ms-python.python        
      ms-python.vscode-pylance
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.cpptools
      ms-vscode.remote-explorer
      MS-vsliveshare.vsliveshare
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
      "vim.enableNeovim" = true;
      # Executable path configurations
      "terraform.languageServer.path"   = "${pkgs.terraform-ls}/bin/terraform-ls";
      "pylsp.executable"                = "${pkgs.python3.pkgs.python-lsp-server}/bin/pylsp";
      "vscode-kubernetes.kubectl-path"  = "${pkgs.kubectl}/bin/kubectl";
      "vscode-kubernetes.helm-path"     = "${pkgs.kubernetes-helm}/bin/helm";
      "ansible.ansible.path"            = "${pkgs.ansible}/bin/ansible";
      "vim.neovimPath"                  = "${pkgs.neovim}/bin/nvim";
      "clangd.path"                     = "${pkgs.clang-tools}/bin/clangd";
    };
  };

  home.packages = with pkgs; [
    # Desktop item overrides
    (hiPrio vscode-wayland)
    (hiPrio slack-wayland)
    (hiPrio brave-wayland)

    # Web browsers
    brave

    # Chat apps
    slack # Slack chat app
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
