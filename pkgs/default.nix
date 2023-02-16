final: prev:
let
  myPythonPackages = {
    xonsh-direnv = prev.callPackage ../pkgs/python3Packages/xonsh-direnv { };
    xontrib-fzf-widgets = prev.callPackage ../pkgs/python3Packages/xontrib-fzf-widgets { };
    xontrib-sh = prev.callPackage ../pkgs/python3Packages/xontrib-sh { };
    xontrib-argcomplete = prev.callPackage ../pkgs/python3Packages/xontrib-argcomplete { };
    xontrib-output-search = prev.callPackage ../pkgs/python3Packages/xontrib-output-search { };
    xontrib-jump-to-dir = prev.callPackage ../pkgs/python3Packages/xontrib-jump-to-dir { };
    xonsh-joined-deps = prev.callPackage ../pkgs/python3Packages/xonsh-joined-deps { };
    xonsh-autoxsh = prev.callPackage ../pkgs/python3Packages/xonsh-autoxsh { };
    tokenize-output = prev.callPackage ../pkgs/python3Packages/tokenize-output { };
    lazyasd = prev.callPackage ../pkgs/python3Packages/lazyasd { };
  };
in{
  splunk-otel-collector = prev.callPackage ../pkgs/splunk-otel-collector { };
  salt-pepper = prev.callPackage ../pkgs/salt-pepper { };
  acme-dns = prev.callPackage ../pkgs/acme-dns { };
  slack-wayland = prev.callPackage ../pkgs/desktopItemOverrides/slack.nix { };
  vscode-wayland = prev.callPackage ../pkgs/desktopItemOverrides/vscode.nix { };
  brave-wayland = prev.callPackage ../pkgs/desktopItemOverrides/brave.nix { };
  python3Packages = prev.python3Packages // myPythonPackages;
  python3 = prev.python3.override {
    packageOverrides = final: prev: { } // myPythonPackages;
  };
  vscode-extensions = prev.vscode-extensions // {
    jnoortheen.xonsh = prev.callPackage ../pkgs/vscode-extensions/jnoortheen.xonsh { };
    EditorConfig.EditorConfig = prev.callPackage ../pkgs/vscode-extensions/EditorConfig.EditorConfig { };
  };
  nodePackages = prev.nodePackages // (prev.callPackages ./node-packages {});
}
