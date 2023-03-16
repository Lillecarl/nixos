final: prev: flake:
let
  # python3 packages
  python3Packages = {
    xonsh-direnv = prev.callPackage ../pkgs/python3Packages/xonsh-direnv { };
    xontrib-argcomplete = prev.callPackage ../pkgs/python3Packages/xontrib-argcomplete { };
    xontrib-autoxsh = prev.callPackage ../pkgs/python3Packages/xontrib-autoxsh { };
    xontrib-fzf-widgets = prev.callPackage ../pkgs/python3Packages/xontrib-fzf-widgets { };
    xontrib-jump-to-dir = prev.callPackage ../pkgs/python3Packages/xontrib-jump-to-dir { };
    xontrib-onepath = prev.callPackage ../pkgs/python3Packages/xontrib-onepath { };
    xontrib-output-search = prev.callPackage ../pkgs/python3Packages/xontrib-output-search { };
    xontrib-sh = prev.callPackage ../pkgs/python3Packages/xontrib-sh { };
    tokenize-output = prev.callPackage ../pkgs/python3Packages/tokenize-output { };
    lazyasd = prev.callPackage ../pkgs/python3Packages/lazyasd { };

    exabgp = prev.callPackage ../pkgs/python3Packages/exabgp { };

    pyzmq25 = prev.python3Packages.callPackage ../pkgs/python3Packages/pyzmq { };
    looseversion = prev.python3Packages.callPackage ../pkgs/python3Packages/looseversion { };

    pytest-salt-factories = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-salt-factories { };
    pytest-shell-utilities = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-shell-utilities { };
    pytest-skip-markers = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-skip-markers { };
    pytest-tempdir = prev.python3Packages.callPackage ../pkgs/python3Packages/pytest-tempdir { };

    ifupdown2 = prev.python3Packages.callPackage ../pkgs/python3Packages/ifupdown2 { };
  };
  nodePackages = (prev.callPackages ./node-packages { });
in
prev.lib.filterAttrs
  (n: v: flake == false ||
  # Flake is implicitly true here
  # Filter out package sets if we're called from a flake.
  (n != "python3Packages" && n != "nodePackages"))
  {
    # Stand-alone packages
    acme-dns = prev.callPackage ../pkgs/acme-dns { };
    salt-pepper = prev.callPackage ../pkgs/salt-pepper { };
    splunk-otel-collector = prev.callPackage ../pkgs/splunk-otel-collector { };

    xonsh-joined = prev.callPackage ../pkgs/xonsh-joined { };
    xonsh-wrapper = final.callPackage ../pkgs/xonsh-wrapper { };

    #salt = prev.salt.overrideAttrs (final: prev: {
    #  src = /home/lillecarl/Code/nent/saltstack;
    #});

    # Newer salt version, currently in development
    salt3006 = prev.callPackage ./salt { };
    # Desktop items to enable Wayland for packages that prefer X
    brave-wayland = prev.callPackage ../pkgs/desktopItemOverrides/brave.nix { };
    slack-wayland = prev.callPackage ../pkgs/desktopItemOverrides/slack.nix { };
    vscode-wayland = prev.callPackage ../pkgs/desktopItemOverrides/vscode.nix { };
    # Inject python3 packages
    python3Packages = python3Packages // prev.python3Packages;
    python3 = prev.python3.override {
      packageOverrides = final: prev: { } // python3Packages;
    };
    # Inject node packages
    nodePackages = nodePackages // prev.nodePackages;
  }
// (if flake == true then python3Packages else { })
  // (if flake == true then nodePackages else { })
