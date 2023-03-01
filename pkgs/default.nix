final: prev:
let
  # python3 packages
  myPythonPackages = {
    xonsh-direnv = prev.callPackage ../pkgs/python3Packages/xonsh-direnv { };
    xontrib-fzf-widgets = prev.callPackage ../pkgs/python3Packages/xontrib-fzf-widgets { };
    xontrib-sh = prev.callPackage ../pkgs/python3Packages/xontrib-sh { };
    xontrib-argcomplete = prev.callPackage ../pkgs/python3Packages/xontrib-argcomplete { };
    xontrib-output-search = prev.callPackage ../pkgs/python3Packages/xontrib-output-search { };
    xontrib-jump-to-dir = prev.callPackage ../pkgs/python3Packages/xontrib-jump-to-dir { };
    xontrib-onepath = prev.callPackage ../pkgs/python3Packages/xontrib-onepath { };
    xonsh-joined-deps = prev.callPackage ../pkgs/python3Packages/xonsh-joined-deps { };
    xonsh-autoxsh = prev.callPackage ../pkgs/python3Packages/xonsh-autoxsh { };
    tokenize-output = prev.callPackage ../pkgs/python3Packages/tokenize-output { };
    lazyasd = prev.callPackage ../pkgs/python3Packages/lazyasd { };

    pyzmq25 = prev.python3Packages.callPackage ../pkgs/python3Packages/pyzmq { };
    looseversion = prev.python3Packages.callPackage ../pkgs/python3Packages/looseversion { };

    pytest-shell-utilities = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-shell-utilities { };
    pytest-skip-markers = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-skip-markers { };
    pytest-salt-factories = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-salt-factories { };
  };
in
{
  # Stand-alone packages
  splunk-otel-collector = prev.callPackage ../pkgs/splunk-otel-collector { };
  salt-pepper = prev.callPackage ../pkgs/salt-pepper { };
  acme-dns = prev.callPackage ../pkgs/acme-dns { };
  xonsh = prev.callPackage ../pkgs/xonsh { };

  #salt = prev.salt.overrideAttrs (final: prev: {
  #  src = fetchGit "/home/lillecarl/Code/nent/saltstack/";
  #});
  # Desktop items to enable Wayland for packages that prefer X
  slack-wayland = prev.callPackage ../pkgs/desktopItemOverrides/slack.nix { };
  vscode-wayland = prev.callPackage ../pkgs/desktopItemOverrides/vscode.nix { };
  brave-wayland = prev.callPackage ../pkgs/desktopItemOverrides/brave.nix { };
  # Inject python3 packages
  python3Packages = prev.python3Packages // myPythonPackages;
  python3 = prev.python3.override {
    packageOverrides = final: prev: { } // myPythonPackages;
  };
  # Inject node packages
  nodePackages = prev.nodePackages // (prev.callPackages ./node-packages { });
}
