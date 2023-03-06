{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      lillecarl = {
        id = 1337;
        isDefault = true;
      };
      empty = {
        id = 321;
      };
    };
  };

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

    package = pkgs.vscode;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (
      builtins.fromJSON (
        builtins.readFile ../pkgs/vscodeExtensions.json));

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
    teams-for-linux # Open-Source Teams Electron App
    discord # Gaming chat application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    #vlc # VLC sucks in comparision to MPV
  ];
}
